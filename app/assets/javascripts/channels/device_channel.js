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
      switch(data.action) {
        case 'create':
          this.createRow(data);
          break;
        case 'update':
          this.updateRow(data);
          break;
        case 'destroy':
          this.destroyRow(data);
          break;
      }
    },
    createRow(data) {
      $('#user-agent-table table tbody').append(data.device_html);
    },
    updateRow(data) {
      $(`[data-device-id=${data.device_id}]`).replaceWith(data.device_html);
      this.updateSidebar(data);
    },
    destroyRow(data) {
      $(`[data-device-id=${data.device_id}]`).remove();
    },
    updateSidebar(data) {
      if ($('#sidebar-scans').length) {
        $('#sidebar-scans').replaceWith(data.sidebar_html);
      };
    }
  });
});
