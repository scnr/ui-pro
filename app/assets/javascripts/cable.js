//= require actioncable
//= require_self
//= require_tree ./channels

function getCableChannel() {
  return $('meta[name=action-cable-channel]').attr('content');
};

function loadChannel(targetChannel, currentChannel = getCableChannel()) {
  return targetChannel === currentChannel
};

function alreadySubscribed(channel) {
  return App.cable.subscriptions.subscriptions.some(function(subscription) {
    return JSON.parse(subscription.identifier).channel == channel
  });
};

(function() {
  this.App || (this.App = {});
  App.cable = ActionCable.createConsumer($('meta[name=action-cable-url]').attr('content'));
}).call(this);

// Unsubscribe current user from the redundant channels.
$(document).on('turbo:load', function() {
  App.cable.subscriptions.subscriptions.forEach(function(subscription) {
    if (JSON.parse(subscription.identifier).channel == getCableChannel()) {
      return;
    };

    subscription.unsubscribe();
  });
});
