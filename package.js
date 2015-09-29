READPackage.describe({
  name: 'ccorcos:utils',
  summary: 'Utilites missing from Underscore and Ramda',
  version: '0.0.1',
  git: 'https://github.com/ccorcos/meteor-utils'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  var packages = [
    'underscore',
    'ramda:ramda@0.17.1',
    'random',
    'check',
    'coffeescript',
  ];
  api.use(packages);
  api.imply(packages);
  api.addFiles(['globals.js', 'utils.coffee']);
  api.addFiles(['server-utils.coffee'], 'server');
  api.export(['U']);
});
