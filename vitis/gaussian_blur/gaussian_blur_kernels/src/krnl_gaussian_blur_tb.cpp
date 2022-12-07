#include <random>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <common/xf_headers.hpp>
#include <common/xf_utility.hpp>

#define SIZE (64 * 64)

void krnl_gaussian_blur(ap_uint<8> *, ap_uint<8> *, const uint16_t rows,
                        const uint16_t cols);

extern "C" {

// void krnl_gaussian_blur(const uint8_t *in, uint8_t *out, const uint16_t rows,
// const uint16_t cols);
}

bool verify(const cv::Mat out_cvmat, const cv::Mat ref_cvmat, double &max_val,
            cv::Point &max_loc, const uint8_t err_threshold) {
  cv::Mat diff;
  cv::absdiff(out_cvmat, ref_cvmat, diff);
  cv::minMaxLoc(diff, NULL, &max_val, NULL, &max_loc);

  if (err_threshold < max_val) {
    printf("*** NG ***\n");
    return false;
  } else {
    printf("OK.\n");
  }

  return true;
}

void print_result(const cv::Mat in_cvmat, const cv::Mat out_cvmat,
                  const cv::Mat ref_cvmat, const double max_val,
                  const cv::Point max_loc) {
  uint16_t t = MAX(0, max_loc.y - 4);
  uint16_t b = MIN(in_cvmat.rows, max_loc.y + 4);
  uint16_t l = MAX(0, max_loc.x - 4);
  uint16_t r = MIN(in_cvmat.cols, max_loc.x + 4);

  printf("max_val : %lf\n", max_val);
  printf("max_loc : %d, %d\n", max_loc.y, max_loc.x);
  printf("tblr : %u, %u, %u, %u\n", t, b, l, r);

  printf("in_cvmat\n");
  for (uint16_t iy = t; iy < b; iy++) {
    for (uint16_t ix = l; ix < r; ix++) {
      printf("%03u, ", in_cvmat.at<uint8_t>(iy, ix));
    }
    printf("\n");
  }

  printf("ref_cvmat\n");
  for (uint16_t iy = t; iy < b; iy++) {
    for (uint16_t ix = l; ix < r; ix++) {
      printf("%03u, ", ref_cvmat.at<uint8_t>(iy, ix));
    }
    printf("\n");
  }

  printf("out_cvmat\n");
  for (uint16_t iy = t; iy < b; iy++) {
    for (uint16_t ix = l; ix < r; ix++) {
      printf("%03u, ", out_cvmat.at<uint8_t>(iy, ix));
    }
    printf("\n");
  }
}

int main() {
  const int random_seed = 1204;
  std::mt19937 mt(random_seed);
  std::uniform_int_distribution<> u8_rand(0, 255);

  cv::Mat in_cvmat, out_cvmat, ref_cvmat;
  int8_t retval = 0;

  // const uint16_t width = 640;
  // const uint16_t height = 480;
  const uint16_t height = 32;
  const uint16_t width = 64;

  printf("image size : %ux%u\n", width, height);
  // in_cvmat = cv::imread("sample.png", cv::IMREAD_GRAYSCALE);
  in_cvmat.create(cv::Size(width, height), CV_8UC1);
  out_cvmat.create(in_cvmat.size(), CV_8UC1);

  for (uint16_t iy = 0; iy < in_cvmat.rows; iy++) {
    for (uint16_t ix = 0; ix < in_cvmat.cols; ix++) {
      in_cvmat.at<uint8_t>(iy, ix) = u8_rand(mt);
    }
  }

  cv::GaussianBlur(in_cvmat, ref_cvmat, cv::Size(7, 7), 2.0, 2.0,
                   cv::BORDER_REFLECT_101);

  krnl_gaussian_blur((ap_uint<8> *)in_cvmat.data, (ap_uint<8> *)out_cvmat.data,
                     in_cvmat.rows, in_cvmat.cols);

  double max_val;
  cv::Point max_loc;
  const uint8_t err_threshold = 2;
  bool verified = verify(out_cvmat, ref_cvmat, max_val, max_loc, err_threshold);
  retval = verified ? 0 : 1;

  if (retval != 0) {
    print_result(in_cvmat, out_cvmat, ref_cvmat, max_val, max_loc);

    return retval;
  }

  if (true) {
    printf("OK.\n");
  } else {
    printf("*** NG ***\n");
    retval = 1;
  }

  return retval;
}

