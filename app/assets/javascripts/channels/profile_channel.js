$(document).on('turbo:load', function() {
  const channel = 'ProfileChannel';

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
      $('#profiles-table table tbody').append(data.profile_html);
    },
    updateRow(data) {
      $(`[data-profile-id=${data.profile_id}]`).replaceWith(data.profile_html);
      this.updateSidebar(data);
    },
    destroyRow(data) {
      $(`[data-profile-id=${data.profile_id}]`).remove();
    },
    updateSidebar(data) {
      if ($('#sidebar-scans').length) {
        $('#sidebar-scans').replaceWith(data.sidebar_html);
      };
    }
  });
});
