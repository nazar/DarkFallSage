ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'home', :action => 'index'

  map.home '', :controller => 'home', :action => 'index'
  map.privacy 'privacy', :controller => 'home', :action => 'privacy'
  map.reputation 'reputation', :controller => 'home', :action => 'reputation'

  # See how all your routes lay out with "rake routes"
  #session
  map.session_login    '/sessions/login',           :controller => 'sessions', :action => 'login'
  map.session_signup   '/sessions/signup',          :controller => 'sessions', :action => 'signup'
  map.session_activate '/sessions/activate/:token', :controller => 'sessions', :action => 'activate'

  #user profiles
  map.profile               '/profile/:login',               :controller => 'profiles', :action => 'show'
  map.images_profile        '/profile/:login/images',        :controller => 'profiles', :action => 'images'
  map.edit_profile          '/profile/:login/edit',          :controller => 'profiles', :action => 'edit'
  map.comments_profile      '/profile/:login/comments',      :controller => 'profiles', :action => 'comments'
  map.settings_profile      '/profile/:login/settings',      :controller => 'profiles', :action => 'settings'
  map.notifications_profile '/profile/:login/notifications', :controller => 'profiles', :action => 'notifications'

  #admin
  map.admin                 'admin',                         :controller => 'admin/admin'

  #articles
  map.category_articles    '/articles/list/:id/:name',      :controller => 'articles', :action => 'list'
  map.article_view         '/articles/view/:id/:name',      :controller => 'articles', :action => 'view'
  map.article              '/articles/view/:id',            :controller => 'articles', :action => 'view'  

   # comments
  map.edit_comment         '/comments/edit/:id',                          :controller => 'comments', :action => 'edit'
  map.delete_comment       '/comments/delete/:id',                        :controller => 'comments', :action => 'delete'

  #forums
  map.forum_home           '/forums',                                     :controller => 'forums', :action => 'index'
  map.forum                '/forums/:id',                                 :controller => 'forums', :action => 'show'

  #topics
  map.topic                '/topic/:id',                                               :controller => 'topics', :action => 'show'
  map.new_topic            '/topics/new/:topicable_type/:topicable_id',                :controller => 'topics', :action => 'new'
  map.create_topic         '/topics/create/:topicable_type/:topicable_id',             :controller => 'topics', :action => 'create'
  map.reply_topic          '/topics/reply/:id',                                        :controller => 'topics', :action => 'reply'
  map.prev_topic           '/topics/:id/prev',                                         :controller => 'topics', :action => 'previous'
  map.next_topic           '/topics/:id/next',                                         :controller => 'topics', :action => 'next'
  map.all_user_topics      '/topics/all/by/:login',                                  :controller => 'topics', :action => 'by_user'

  #posts
  map.reply_post           '/posts/reply/:id',                                         :controller => 'posts', :action => 'reply'
  map.edit_post            '/posts/edit/:id',                                          :controller => 'posts', :action => 'edit'
  map.delete_post          '/posts/delete/:id',                                        :controller => 'posts', :action => 'delete'
  map.quote_post           '/posts/quote/:id',                                         :controller => 'posts', :action => 'quote'
  map.all_user_posts       '/posts/all/by/:login',                                   :controller => 'posts', :action => 'by_user'

  #fckeditor hacks
  map.connect 'fckeditor/check_spelling', :controller => 'fckeditor', :action => 'check_spelling'
  map.connect 'fckeditor/command', :controller => 'fckeditor', :action => 'command'
  map.connect 'fckeditor/upload', :controller => 'fckeditor', :action => 'upload'

  #items database
  map.resources :items, :collection => {:properties => :get}
  map.items_by_type         'items/by/type/:id',                                        :controller => 'items', :action => 'by_type'    
  map.items_type_sub        'items/by/type/:id/sub/:sub',                               :controller => 'items', :action => 'by_sub_type'
  map.item_markers          'items/markers/:id',                                        :controller => 'items',  :action => 'markers' 
  map.item_my_markers       'items/my/:user_id/markers/:id',                            :controller => 'items',  :action => 'my_markers'

  #skills
  map.resources :skills, :collection => {:properties => :get}
  map.skill_by_type        'skills/by/type/:id',                                        :controller => 'skills', :action => 'by_type'

  #prereqs
  map.prereq_line          'prereqs/prereq',                                            :controller => 'prereqs', :action => 'prereq'
  map.prereq_object_list   'prereqs/type_objects/:id/:type',                            :controller => 'prereqs', :action => 'type_objects'

  #spell reagents
  map.reagent_line         'spells_reagents/reagent',                                   :controller => 'spell_reagents', :action => 'reagent'

  #ability
  map.ability              'abilities/:id',                                             :controller => 'abilities', :action => 'show'

  #spells
  map.resources :spells
  map.spell_by_type        'spells/by/effect/:id',                                      :controller => 'spells', :action => 'by_effect'                         
  map.spell_by_school      'spells/by/school/:id',                                      :controller => 'spells', :action => 'by_school'                  

  #news
  map.view_news             'news/show/:id',                                            :controller => 'news', :action => 'show'
  map.news                  'news/show/:id',                                            :controller => 'news', :action => 'show'
  #news categoryes
  map.news_category         'news/by/category/:id',                                     :controller => 'news', :action => 'by_category'

  #IRC
  map.irc '/irc',                                                                       :controller => 'irc', :action => 'index'

  #images
  #map.resources :images
  map.new_image              'images/new/:imageable_type/:imageable_id',                :controller => 'images', :action => 'new'              
  map.images                 'images/create/:imageable_type/:imageable_id',             :controller => 'images', :action => 'create'
  map.image                  'images/show/:id',                                         :controller => 'images', :action => 'show'

  #mobs
  map.resources :mobs,
                :collection => {:properties => :get, :drops => :get, :skins => :get, :casts => :get, :sells => :get, :sells_spells => :get, :sells_items => :get}
  map.mob_revisions        'mobs/revisions/:id/:revision',                            :controller => 'mobs',  :action => 'revisions'
  map.mob_approve          'mobs/approve/:id',                                        :controller => 'mobs',  :action => 'approve'
  map.mob_revert           'mobs/revert/:id',                                         :controller => 'mobs',  :action => 'revert'            
  map.mob_edit_submit      'mobs/edit_submit/:id',                                    :controller => 'mobs',  :action => 'edit_submit'
  map.mob_markers          'mobs/markers/:id',                                        :controller => 'mobs',  :action => 'markers'
  map.mob_my_markers       'mobs/my/:user_id/markers/:id',                            :controller => 'mobs',  :action => 'my_markers'
  map.mob_filter           'mobs/filter/:letter',                                     :controller => 'mobs',  :action => 'by_letter'
  map.unapproved_mob       'mobs/unapproved/list',                                    :controller => 'mobs',  :action => 'unapproved'   

  #poi - points of interest
  map.resources :pois, :as => 'points_of_interest'
  map.poi_edit_submit      'pois/edit_submit/:id',                                    :controller => 'pois', :action => 'edit_submit'
  map.poi_revisions        'pois/revisions/:id/:revision',                            :controller => 'pois', :action => 'revisions'
  map.poi_approve          'pois/approve/:id',                                        :controller => 'pois', :action => 'approve'
  map.poi_revert           'pois/revert/:id',                                         :controller => 'pois', :action => 'revert'
  map.poi_markers          'pois/markers/:id',                                        :controller => 'pois', :action => 'markers'
  map.poi_my_markers       'pois/my/:user_id/markers/:id',                            :controller => 'pois', :action => 'my_markers'

  #voting
  map.vote_cast            'votes/cast/:class/:id/:vote',                             :controller => 'votes', :action => 'cast'

  #maps
  map.add_map              'maps/add/marker/:markable_type/:markable_id',             :controller => 'maps', :action => 'add_obj_marker'

  #clans
  map.resources :clans
  map.clan_expel_member     'clans/expel/:clan_id/member/:member_id',                 :controller => 'clans', :action => 'expel'     
  map.change_rank_member    'clans/rank/:clan_id/member/:member_id',                  :controller => 'clans', :action => 'rank'     


  #clan forums
  map.clan_forums           'clans/forums/:clan_id',                                  :controller => 'clan_forums', :action => 'index'
  map.clan_forums_admin     'clans/forums/:clan_id/admin',                            :controller => 'clan_forums', :action => 'admin'
  map.clan_forums_new       'clans/forums/:clan_id/new',                              :controller => 'clan_forums', :action => 'new'
  map.clan_forums_create    'clans/forums/:clan_id/create',                           :controller => 'clan_forums', :action => 'create'
  map.clan_forums_edit      'clans/forums/:forum_id/edit',                            :controller => 'clan_forums', :action => 'edit'
  map.clan_forums_update    'clans/forums/:forum_id/delete',                          :controller => 'clan_forums', :action => 'create'
  map.clan_forums_destroy   'clans/forums/:forum_id/destroy',                         :controller => 'clan_forums', :action => 'destroy'
  map.clan_forums_show      'clans/forums/:forum_id/show',                            :controller => 'clan_forums', :action => 'show'
  map.clan_forum            'clans/forum/:forum_id',                                  :controller => 'clan_forums', :action => 'show'

  #clan applications
  map.clan_application_show   'clans/application/:id/show',                           :controller => 'clan_applications', :action => 'show' 
  map.clan_application_accept 'clans/application/:id/accept',                         :controller => 'clan_applications', :action => 'accept'
  map.clan_application_reject 'clans/application/:id/reject',                         :controller => 'clan_applications', :action => 'reject'

  #clan invitations
  map.clan_invitation_users   'clan_invites/lookup/:clan_id',                         :controller => 'clan_invites', :action => 'non_members_list'  
  map.clan_invite_accept      'clans/invite/accept/:token',                           :controller => 'clan_invites', :action => 'accept'
  map.clan_invite_reject      'clans/invite/reject/:token',                           :controller => 'clan_invites', :action => 'reject'
  map.clan_invite_delete      'clans/invite/delete/:id',                              :controller => 'clan_invites', :action => 'delete'

  #clan alliances
  map.resources :alliances
  map.alliance_join           'clans/alliance/:id/join',                              :controller => 'alliances', :action => 'join'
  map.alliance_leave          'clans/alliance/:id/leave',                             :controller => 'alliances', :action => 'leave'
  map.alliance_delete         'clans/alliance/:id/delete',                            :controller => 'alliances', :action => 'destroy' 
  map.clan_alliance_new       'clans/alliance/:clan_id/new',                          :controller => 'alliances', :action => 'new'
  map.clan_alliance_invite    'clans/alliance/:invite_clan/invite/:alliance',         :controller => 'alliances', :action => 'invite'
  map.clan_alliance_create_invite 'clans/alliance/:my_clan/new_invite/:invite_clan',  :controller => 'alliances', :action => 'new_and_invite'

  #alliance clans
  map.alliance_clan_accept        'clans/proposal/:token/accept',                       :controller => 'alliance_clans', :action => 'accept'
  map.alliance_clan_reject        'clans/proposal/:token/reject',                       :controller => 'alliance_clans', :action => 'reject'
  map.alliance_clan_expel         'clans/proposal/:token/expel',                        :controller => 'alliance_clans', :action => 'expel'
  map.alliance_clan_invite_accept 'clans/clan_invite/:token/accept',                    :controller => 'alliance_clans', :action => 'invite_accept'
  map.alliance_clan_invite_reject 'clans/clan_invite/:token/reject',                    :controller => 'alliance_clans', :action => 'invite_reject'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
  map.connect ':controller'
end
