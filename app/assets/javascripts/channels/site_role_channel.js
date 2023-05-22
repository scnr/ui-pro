$(document).on('turbo:load', function() {
  const channel = 'SiteRoleChannel';

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
          this.createSiteRole(data);
          this.updateSidebar(data);
          break;
        case 'update':
          this.updateSiteRole(data);
          this.updateSidebar(data);
          break;
        case 'destroy':
          this.destroySiteRole(data);
          this.updateSidebar(data);
          break
      };
  },
    createSiteRole(data) {
      $('#roles-table tbody').append(data.site_role_html);
    },
    updateSiteRole(data) {
      $(`[data-site-role-id="${data.site_role_id}"]`).replaceWith(data.site_role_html);
    },
    destroySiteRole(data) {
      $(`[data-site-role-id="${data.site_role_id}"]`).remove();
    },
    updateSidebar(data) {
      if ($("#sidebar-scans").length) {
        $("#sidebar-scans").replaceWith(data.sidebar_html);
      };
    }
  });
});
