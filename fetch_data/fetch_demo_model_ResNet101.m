
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading demo_models_ResNet-101L...\n');
    urlwrite('https://onedrive.live.com/download?resid=F371D9563727B96F!91964&authkey=!AOk8r5H95KFO0e8', ...
        'demo_models_ResNet-101L.zip');

    fprintf('Unzipping...\n');
    unzip('demo_models_ResNet-101L.zip', '..');

    fprintf('Done.\n');
    delete('demo_models_ResNet-101L.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
