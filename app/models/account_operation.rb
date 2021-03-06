class AccountOperation < ActiveRecord::Base

  require 'net/https'
  require 'json'
  require "uri"
  $trans_url = "http://127.0.0.1:8080/accounting/account/execute_cmd"
  $query_url = "http://127.0.0.1:8080/accounting/account/query_cmd"
  attr_accessor :op_obj, :op_id_head
  $dict = {"create" => "创建",
           "product" => "产品",
           "account" => "账户",
           "charge" => "充值",
           "join" => "加入",
           "invest" => "投资",
           "onsale" => "出让",
           "profit" => "付息"
  }
  $error_code = ["无", "记录已存在", "保存失败", "帐号不存在", "产品不存在", "账户余额不足", "个人额度不足", "产品余额不足", "系统内部错误", "资产已经在售",
  "资产不存在", "产品非转让状态", "无利息需支付"]

  def execute_transaction
    d = Time.now.to_i
    self.operation_id = self.op_id_head + d.to_s
    data = {:op_name => self.op_name, :op_amount => self.op_amount, :op_action => self.op_action, :operator => self.operator,
            :user_id => self.user_id, :operation_id => self.operation_id, :op_obj => self.op_obj, :op_resource_id => self.op_resource_id,
            :op_obj => self.op_obj, :op_resource_name => self.op_resource_name, :api_key => "secret"
    }
    # data = self.as_json
    self.save!
    # self.perform($trans_url, data, self.id)
    AccountWorker.perform_async($trans_url, data, self.id)
  end


  def execute_query
    uri = URI.parse($query_url)
    http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    data= {:api_key => "secret", :op_name => self.op_name, :op_amount => self.op_amount, :op_action => self.op_action, :operator => self.operator,
           :user_id => self.user_id, :operation_id => self.operation_id}
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = data.to_json
    response = http.request(request)
    op_res = JSON.parse response.body
  end


  def attach_action
    if self.op_result
      send(self.op_action + "_" + self.op_name)
    end
  end

  def create_product
    product = Product.find(self.op_resource_id)
    product.stage = "已入库"
    product.save!
  end


  def fill_params(params)
    self.op_result = params["op_result"]
    self.op_amount = params["op_amount"]
    self.op_asset_id = params["op_asset_id"]
    self.op_result_code = params["op_result_code"]
    self.op_result_value = params["op_result_value"]
    self.uinfo_id2 = params["uinfo_id2"]
    self.op_result_value2 = params["op_result_value2"]
    self.op_resource_name = params["op_resource_name"]
  end


  def execute_update(objs)
    if self.op_result
      send(self.op_action + "_" + self.op_name, objs)
    end
  end


  def profit_invest(objs)
    # puts objs.to_s
    profits = JSON.parse objs
    product = Product.find_by deposit_number: self.op_resource_name
    product.add_profit_record(self.op_result_value)
    # inv = Invest.find_by asset_id: p["account_sub_invest_id"]
    Invest.update_profits(profits)
    product.locked = false
    product.save!
  end

  def principal_invest(objs)
    # puts objs.to_s
    principals = JSON.parse objs
    product = Product.find_by deposit_number: self.op_resource_name
    product.add_principal_record(self.op_result_value)
    # inv = Invest.find_by asset_id: p["account_sub_invest_id"]
    Invest.update_principals(principals)
    product.locked = false
    product.save!
  end


  def join_invest

  end

  def onsale_invest

  end


  def op_name_cn
    if self.op_name
      $dict[self.op_name]
    end
  end

  def op_action_cn
    if self.op_action
      $dict[self.op_action]
    end
  end

  def op_result_cn
    if self.op_result
      "成功"
    else
      "失败"
    end
  end

  def op_error_cn
    if self.op_result_code
      $error_code[self.op_result_code]
    else
      "无"
    end
  end

end
