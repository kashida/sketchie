chrome.browserAction.onClicked.addListener ->
  chrome.tabs.getSelected null, (tab) ->
    if (tab.url.match /^file\:.*\/femto5\/data\/.*$/i)
      chrome.tabs.insertCSS null, {file:"femto.css"}
      chrome.tabs.executeScript null, {file:"femto.js"}, ->
        chrome.tabs.executeScript null, {code:"run_femto(true);"}
    else
      chrome.tabs.create {url:'newpage.html'}

oauth = ChromeExOAuth.initBackgroundPage {
  request_url: 'https://api.dropbox.com/1/oauth/request_token'
  authorize_url: 'https://www.dropbox.com/1/oauth/authorize'
  access_url: 'https://api.dropbox.com/1/oauth/access_token'
  consumer_key: 'j02gcl24psqaa92'
  consumer_secret: '5myrv5lo2pjd9dt'
  app_name: 'femto'
}

dbreq = (url, method, params, cb) ->
  request = { 'method': method }
  request.parameters = params if params?
  oauth.authorize -> (oauth.sendSignedRequest url, cb, request)

chrome.extension.onRequest.addListener (req, sender, sendResponse) ->
  switch req[0]
    when 'list'
      dbreq 'https://api.dropbox.com/1/metadata/', 'GET', null, (resp, xhr) ->
        console.log xhr
        sendResponse resp
    else
      sendResponse 'error'
