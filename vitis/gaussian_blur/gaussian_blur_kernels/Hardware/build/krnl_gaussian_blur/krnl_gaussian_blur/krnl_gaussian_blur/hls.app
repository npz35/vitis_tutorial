<project xmlns="com.autoesl.autopilot.project" name="krnl_gaussian_blur" top="krnl_gaussian_blur">
    <includePaths/>
    <libraryPaths/>
    <Simulation argv="">
        <SimFlow name="csim" ldflags="-lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6" mflags="" csimMode="0" lastCsimMode="0" setup="false" optimizeCompile="false" clean="false"/>
    </Simulation>
    <files xmlns="">
        <file name="../../../../../../src/krnl_gaussian_blur_tb.cpp" sc="0" tb="1" cflags=" -I/home/np/ghq/github.com/Xilinx/Vitis_Libraries/vision/L1/include  -I/usr/include/opencv4  -L/lib/x86_64-linux-gnu -lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6 -Wno-unknown-pragmas" csimflags=" -I/home/np/ghq/github.com/Xilinx/Vitis_Libraries/vision/L1/include  -I/usr/include/opencv4  -L/lib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu -lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6 -Wno-unknown-pragmas" blackbox="false"/>
        <file name="../../../../src/krnl_gaussian_blur.cpp" sc="0" tb="false" cflags="-I/home/np/ghq/github.com/Xilinx/Vitis_Libraries/vision/L1/include -I/home/np/ghq/gitlab.banana-shake.com/npz35/vitis_tutorial/vitis/gaussian_blur/gaussian_blur_kernels/src" csimflags="" blackbox="false"/>
    </files>
    <solutions xmlns="">
        <solution name="solution" status="active"/>
    </solutions>
</project>

