
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading region proposals...\n');
    urlwrite('https://onedrive.live.com/download?resid=F371D9563727B96F!91965&authkey=!AErVqYD6NhjxAfw', ...
        'proposals.zip');

    fprintf('Unzipping...\n');
    unzip('proposals.zip', '..');

    fprintf('Done.\n');
    delete('proposals.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/daijifeng001/R-FCN'); 
end

cd(cur_dir);
