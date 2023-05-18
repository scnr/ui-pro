$(document).on('turbo:load', function() {
  if (!loadChannel('SitesChannel', getCableChannel())) {
    return;
  };

  App.cable.subscriptions.create('SitesChannel', {
    received(data) {
      this.enusreTablePresence();

      switch(data.action) {
        case 'create':
          this.createSite(data);
          break;
        case 'update':
          this.updateSite(data);
          break;
        case 'destroy':
          this.destroySite(data);
          break
      };
    },
    enusreTablePresence() {
      if ($('#sites-container table').is(':visible')) {
        return;
      };

      $('#sites-container table').removeClass('hidden');
    },
    createSite(data) {
      $('#sites-container tbody').prepend(data.html);
    },
    updateSite(data) {
      $(`[data-site-id="${data.site_id}"]`).replaceWith(data.html);
    },
    destroySite(data) {
      $(`[data-site-id="${data.site_id}"]`).remove();

      if ($('#sites-container tbody').children().length === 0) {
        $('#sites-container table').addClass('hidden');
      };
    }
  });
});
