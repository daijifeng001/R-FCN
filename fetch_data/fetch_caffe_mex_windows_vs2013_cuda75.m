
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading caffe_mex...\n');
    urlwrite('https://onedrive.live.com/download?resid=F371D9563727B96F!91961&authkey=!AOkZbLTBfuMB69Y', ...
        'caffe_mex.zip');

    fprintf('Unzipping...\n');
    unzip('caffe_mex.zip', '..');

    fprintf('Done.\n');
    delete('caffe_mex.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
