hugo -D
rm -rf docs/
mv public/ docs/
git add docs/
git commit -m"hugo build"
git push origin master
