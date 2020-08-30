rm -rf docs/
hugo -d docs/ -D
git add docs/
git commit -m"hugo build"
git push origin master
