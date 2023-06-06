$(document).on('turbo:load', function() {
  const channel = 'ScanChannel';

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
          break
      };
    },
    createRow(data) {
      $(`#site-scans-${data.status} tbody`).append(data.scan_html);
    },
    updateRow(data) {
      const tableRow = $(`[data-scan-id="${data.scan_id}"]`);
      const currentTableContainer = tableRow.closest('.table-container').attr('id');
      const newTableContainer = `site-scans-${data.status}`;

      if (currentTableContainer === newTableContainer) {
        tableRow.replaceWith(data.scan_html);
      } else {
        tableRow.remove();
        this.createRow(data);
      }
    },
    destroyRow(data) {
      $(`[data-scan-id="${data.scan_id}"]`).remove();
    }
  });
});
