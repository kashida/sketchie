chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('page.html', {
    // This id is necessary for the window position / size to persiste across
    // restarts.
    'id': 'filelist',
    'bounds': {
      'width': 400,
      'height': 500
    }
  });
});
