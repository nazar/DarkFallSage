module ClanForumsHelper

  def forum_access_type_select_options
    ClanForum.access_types.sort{|a,b|a[1]<=>b[1]}.collect{|i|[i.last, i.first]}
  end

  def forum_rank_select_options(options={})
    options[:all_ranks] = options[:all_ranks] == true ? {0 => 'All Ranks'} : {}
    ClanMember.ranks.merge(options[:all_ranks]).sort{|a,b|a[0]<=>b[0]}.collect{|i|[i.last, i.first]}
  end

  
end
