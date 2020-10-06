nfs="1.1.1.1:/home/nfs/data/app"

change_file=($(rsync --dry-run -rcnC --out-format="%n" ./ $nfs \
--exclude ".git" \))
for file in ${change_file[*]}
do
    rsync -av $file  $nfs/$file
done
