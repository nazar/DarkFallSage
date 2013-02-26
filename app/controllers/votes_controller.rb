class VotesController < ApplicationController

  def cast     #TODO method too long
    is_reputable_to do
      klass     = params[:class].constantize
      klass_sym = params[:class].downcase.to_sym
      votable = klass.find_by_id params[:id]
      unless votable.blank?
        unless current_user.voted_on?(votable)
          if votable.respond_to?('can_vote')
            can_vote, reason = votable.can_vote(current_user)
          else
            can_vote = true
          end
          #
          if can_vote
            User.transaction do
              current_user.vote(votable, params[:vote])
              Reputation.record_reputation_by_class(klass_sym, votable.class.base_class.to_s, User.find_by_id(votable.user_id), current_user, params[:vote] == 'true' ? :good : :bad)
            end
            respond_to do |format|
              format.html {} #cast.html.erb but shouldn't get here as this is ajaxed
              format.js do
                render :update do |page|
                  page.replace "votes_block_#{votable.id}", :partial => 'votes/vote_block',
                                              :locals => {:voteable => votable,
                                                          :votes_for => votable.votes_for,
                                                          :votes_against => votable.votes_against,
                                                          :voted_for => current_user.voted_for?(votable), :voted_against => current_user.voted_against?(votable)}
                end
              end
            end
          else
            respond_to do |format|
              format.html {render :text => reason}
              format.js do
                render :update do |page|
                  page.alert(reason)
                end
              end
            end
          end
        else
          respond_to do |format|
            format.html {render :text => 'cannot vote more than once!'}
            format.js do
              render :update do |page|
                page.alert('cannot vote more than once')
              end
            end
          end
        end
      else
        render :text => 'invalid', :status => 404
      end
    end
  end  

end