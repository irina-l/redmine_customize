require File.expand_path('../../../test_helper', __FILE__)
require 'settings_controller'

class RedmineCustomize::SettingsControllerTest < ActionController::TestCase
  fixtures :users, :roles, :members, :member_roles

  def setup
    @controller = SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user = User.find(1) # admin
    User.current = @user
    @request.session[:user_id] = @user.id
    @plugin_id = 'redmine_customize'
  end

  def test_show_empty_settings
    get :plugin, :id => @plugin_id
    assert_response :success
  end

  def test_show_settings
    body, url, title = 'link_body', 'http://example.com', 'link_title'
    item = CustomMenuItem.new(body, url, title)
    cust = Customize.instance
    cust.top_menu_items << item
    cust.save

    get :plugin, :id => @plugin_id
    assert_response :success
  end

  def test_save_settings
    body, url, title = 'link_Xbody', 'http://exampleX.com', 'link_Xtitle'
    attrs = {
        'top_menu_items' => [{ 'body' => body, 'url' => url, 'title' => title }]
    }
    post :plugin, :id => @plugin_id, :settings => attrs
    assert_response :redirect

    Setting.clear_cache
    cust = Customize.instance
    assert_equal 1, cust.top_menu_items.count

    item = cust.top_menu_items[0]
    assert_equal body,  item.body
    assert_equal url,   item.url
    assert_equal title, item.title
  end
end
