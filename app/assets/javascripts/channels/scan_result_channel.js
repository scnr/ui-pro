$(document).on('turbo:load', function() {
  const channel = 'ScanResultChannel';

  if (!loadChannel(channel)) {
    return;
  };

  if (alreadySubscribed(channel)) {
    return;
  };

  App.cable.subscriptions.create(channel, {
    received() {
      $.ajax({
        url: window.location.pathname + window.location.search,
        dataType: 'script'
      })
    }
  });
});
