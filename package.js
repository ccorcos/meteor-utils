Package.describe({
  name: 'ccorcos:utils',
  summary: 'A patchwork of utilites missing from Underscore and Ramda',
  version: '0.0.3',
  git: 'https://github.com/ccorcos/meteor-utils'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2');
  var packages = [
    'underscore',
    'underscorestring:underscore.string@3.2.2',
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
