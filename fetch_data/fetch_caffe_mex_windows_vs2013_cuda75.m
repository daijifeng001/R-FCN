
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading caffe_mex...\n');
    urlwrite('https://www.dropbox.com/s/n1x2bybd6d03s7c/caffe_mex.zip?dl=1', ...
        'caffe_mex.zip');

    fprintf('Unzipping...\n');
    unzip('caffe_mex.zip', '..');

    fprintf('Done.\n');
    delete('caffe_mex.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
