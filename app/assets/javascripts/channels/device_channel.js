$(document).on('turbo:load', function() {
  const channel = 'DeviceChannel';

  if (!loadChannel(channel)) {
    return;
  };

  if (alreadySubscribed(channel)) {
    return;
  };

  App.cable.subscriptions.create(channel, {
    received(data) {
      $(`[data-device-id=${data.device_id}] [data-scan-size]`).text(data.scans_count);
      if ($('#sidebar-scans').length) {
        $('#sidebar-scans').replaceWith(data.sidebar_html);
      };
    }
  });
});
