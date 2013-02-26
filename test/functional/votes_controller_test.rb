require File.dirname(__FILE__) + '/../test_helper'
require 'votes_controller'

# Re-raise errors caught by the controller.
class PhotosController; def rescue_action(e) raise e end; end

class VotesControllerTest < ActionController::TestCase

  def setup
    @controller = VotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #disables spider checks and bans
    @request.session[:testing] = true
  end

  context 'voting tests' do

    setup do 
      @user = create_user
#      @request.session[:user] = @user
    end

    context 'mob markers' do

      setup do
        @mob = Mob.create(:name => 'test name')
        @marker = @mob.markers.create(:user_id => @user.id, :title => 'test marker')
        @reporter = create_user({:login => 'reporter', :email => 'reporter@user.com'}) 
        @request.session[:user] = @reporter
      end

      should 'vote for markable' do
        post :cast, :id => @marker.id, :vote => true
        assert_response :success
        #check votes
        @marker.reload
        assert_equal @marker.votes.length, 1
        assert_equal @marker.votes_count, 1
        assert_equal @marker.votes_for, 1
        assert_equal @marker.votes_against, 0
        #check user
        @user.reload
        assert_equal @reporter.voted_on?(@marker), true
        #check reputation
        assert_equal @reporter.counter.reputation, 10
        assert_equal @user.counter.reputation, 15
        assert_equal @user.reputations.length, 1
      end

      should 'vote against markable' do
        post :cast, :id => @marker.id, :vote => false
        assert_response :success
        #check votes
        @marker.reload
        assert_equal @marker.votes.length, 1
        assert_equal @marker.votes_count, 1
        assert_equal @marker.votes_for, 0
        assert_equal @marker.votes_against, 1
        #check user
        @user.reload
        assert_equal @reporter.voted_on?(@marker), true
        #check reputation
        @reporter.reload
        assert_equal @reporter.counter.reputation, 9
        assert_equal @user.counter.reputation, 8
        assert_equal @user.reputations.length, 1
        assert_equal @reporter.reputations.length, 1
      end



    end


  end

end
