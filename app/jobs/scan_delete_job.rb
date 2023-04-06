class ScanDeleteJob < ApplicationJob
  queue_as :default

  def perform( scan )
    scan.destroying!
    scan.destroy
  end
end
