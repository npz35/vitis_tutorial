#include <ap_int.h>
#include <hls_stream.h>
#include <stdint.h>

#include "common/xf_common.hpp"
#include "common/xf_types.hpp"
#include "common/xf_utility.hpp"

void load_input(const ap_uint<8> *in, hls::stream<ap_uint<8>> &in_stream,
                const uint16_t rows, const uint16_t cols) {
mem_rd:
  for (uint32_t i = 0; i < rows * cols; i++) {
    in_stream << in[i];
  }
}

void store_output(ap_uint<8> *out, hls::stream<ap_uint<8>> &out_stream,
                  const uint16_t rows, const uint16_t cols) {
mem_wr:
  for (uint32_t i = 0; i < rows * cols; i++) {
    out[i] = out_stream.read();
  }
}

const uint16_t max_width = 1920;
const uint8_t kernel_size = 7;
const uint8_t half_kernel_size = kernel_size / 2;
const uint8_t kernel_1d[kernel_size] = {18, 34, 49, 55, 49, 34, 18};
uint8_t gauss_filter(const uint8_t shift_reg[kernel_size][kernel_size]) {
  uint32_t sum = 0;
  for (uint8_t ky = 0; ky < kernel_size; ky++) {
    for (uint8_t kx = 0; kx < kernel_size; kx++) {
      uint16_t a = kernel_1d[ky] * kernel_1d[kx];
      sum += a * shift_reg[ky][kx];
    }
  }

  return ((sum >> 16) & 0xFF);
}

void stream_processing(xf::cv::Mat<XF_8UC1, 32, 64, XF_NPPC1, 1> &in_xfmat,
                       xf::cv::Mat<XF_8UC1, 32, 64, XF_NPPC1, 1> &out_xfmat,
                       const uint16_t rows, const uint16_t cols) {
  uint8_t line_buffer[kernel_size][max_width + kernel_size];
  uint8_t shift_reg[kernel_size][kernel_size];

  for (uint16_t iy = 0; iy < rows + half_kernel_size; iy++) {
    for (uint16_t ix = 0; ix < cols + half_kernel_size; ix++) {
#pragma HLS PIPELINE II = 1
#pragma HLS LOOP_TRIPCOUNT min = max_width max = max_width

      for (uint8_t ky = 0; ky < kernel_size - 1; ky++) {
        shift_reg[ky][kernel_size - 1] = line_buffer[ky][ix];
      }

      if (iy < rows && ix < cols) {
        const uint8_t new_pix = in_xfmat.read(iy * cols + ix);

        shift_reg[kernel_size - 1][kernel_size - 1] = new_pix;
        line_buffer[kernel_size - 1][ix] = new_pix;
      }

      // top padding
      // iy == 0, shift_reg[6][6] = shift_reg[6][6]
      // iy == 1, shift_reg[4][6] = shift_reg[6][6]
      // iy == 2, shift_reg[2][6] = shift_reg[6][6]
      // iy == 3, shift_reg[0][6] = shift_reg[6][6]
      if (iy <= half_kernel_size) {
        uint8_t reflect = kernel_size - 1 - (2 * iy);
        shift_reg[reflect][kernel_size - 1] =
            shift_reg[kernel_size - 1][kernel_size - 1];
      }

      // bottom padding
      // iy == rows+0, shift_reg[6][6] = shift_reg[4][6]
      // iy == rows+1, shift_reg[6][6] = shift_reg[2][6]
      // iy == rows+2, shift_reg[6][6] = shift_reg[0][6]
      if (rows <= iy) {
        uint8_t reflect = (kernel_size - 1) - 2 * (iy - (rows - 1));
        shift_reg[kernel_size - 1][kernel_size - 1] =
            shift_reg[reflect][kernel_size - 1];
      }

      // left padding
      // ix == 0, shift_reg[*][6] = shift_reg[*][6]
      // ix == 1, shift_reg[*][4] = shift_reg[*][6]
      // ix == 2, shift_reg[*][2] = shift_reg[*][6]
      // ix == 3, shift_reg[*][0] = shift_reg[*][6]
      if (ix <= half_kernel_size) {
        uint8_t reflect = kernel_size - 1 - (2 * ix);
        for (uint8_t ky = 0; ky < kernel_size; ky++) {
          shift_reg[ky][reflect] = shift_reg[ky][kernel_size - 1];
        }
      }

      // right padding
      // ix == cols+0, shift_reg[*][6] = shift_reg[*][4]
      // ix == cols+1, shift_reg[*][6] = shift_reg[*][2]
      // ix == cols+2, shift_reg[*][6] = shift_reg[*][0]
      if (cols <= ix) {
        uint8_t reflect = (kernel_size - 1) - 2 * (ix - (cols - 1));
        for (uint8_t ky = 0; ky < kernel_size; ky++) {
          shift_reg[ky][kernel_size - 1] = shift_reg[ky][reflect];
        }
      }

      if (half_kernel_size <= iy && half_kernel_size <= ix) {
        uint8_t out_pix = gauss_filter(shift_reg);
        uint32_t index =
            (iy - half_kernel_size) * cols + (ix - half_kernel_size);
        out_xfmat.write(index, out_pix);
      }

      // shift left
      for (uint8_t ky = 0; ky < kernel_size; ky++) {
        for (uint8_t kx = 0; kx < kernel_size - 1; kx++) {
          shift_reg[ky][kx] = shift_reg[ky][kx + 1];
        }
      }

      // shift up
      for (uint8_t ky = 0; ky < kernel_size - 1; ky++) {
        line_buffer[ky][ix] = shift_reg[ky + 1][kernel_size - 1];
      }
    }
  }
}

#define SIZE (64 * 64)

void krnl_gaussian_blur(ap_uint<8> *in, ap_uint<8> *out, const uint16_t rows,
                        const uint16_t cols) {
#pragma HLS INTERFACE m_axi port = in offset = slave bundle = gmem0 depth = 2048
#pragma HLS INTERFACE m_axi port = out offset = slave bundle = gmem1 depth =   \
    2048

  xf::cv::Mat<XF_8UC1, 32, 64, XF_NPPC1, 1> in_xfmat(32, 64);
  xf::cv::Mat<XF_8UC1, 32, 64, XF_NPPC1, 1> out_xfmat(32, 64);

#pragma HLS dataflow
  xf::cv::Array2xfMat<8, XF_8UC1, 32, 64, XF_NPPC1, 1>(in, in_xfmat);
  stream_processing(in_xfmat, out_xfmat, 32, 64);
  xf::cv::xfMat2Array<8, XF_8UC1, 32, 64, XF_NPPC1, 1>(out_xfmat, out);
}

