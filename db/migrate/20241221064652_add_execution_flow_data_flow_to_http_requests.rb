class AddExecutionFlowDataFlowToHttpRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :http_requests, :execution_flow, :binary
    add_column :http_requests, :data_flow, :binary
  end
end
