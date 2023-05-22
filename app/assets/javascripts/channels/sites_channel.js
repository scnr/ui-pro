$(document).on('turbo:load', function() {
  const channel = 'SitesChannel';

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
    createSite(data) {
      $('#sites-container tbody').prepend(data.site_html);
    },
    updateSite(data) {
      $(`[data-site-id="${data.site_id}"]`).replaceWith(data.site_html);
    },
    destroySite(data) {
      $(`[data-site-id="${data.site_id}"]`).remove();

      if ($('#sites-container tbody').children().length === 0) {
        $('#sites-container table').addClass('hidden');
      };
    }
  });
});
