function rfcn_build()
% rfcn_build()
% --------------------------------------------------------
% R-FCN implementation
% Modified from MATLAB Faster R-CNN (https://github.com/shaoqingren/faster_rcnn)
% Copyright (c) 2016, Jifeng Dai
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

% Compile nms_mex
if ~exist('nms_mex', 'file')
  fprintf('Compiling nms_mex\n');

  mex -O -outdir bin ...
      CXXFLAGS="\$CXXFLAGS -std=c++11"  ...
      -largeArrayDims ...
      functions/nms/nms_mex.cpp ...
      -output nms_mex;
end

if ~exist('nms_gpu_mex', 'file')
   fprintf('Compiling nms_gpu_mex\n');
   addpath(fullfile(pwd, 'functions', 'nms'));
   nvmex('functions/nms/nms_gpu_mex.cu', 'bin');
   delete('nms_gpu_mex.o');
end


