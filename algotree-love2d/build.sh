appname="algotree"
if [ -f ${appname}.love ]; then
  rm ${appname}.love
fi
zip -ru ${appname}.love main.lua conf.lua assets/* src/*
