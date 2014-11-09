git add -A
git commit -m %1
git push
docpad deploy-ghpages --env static
