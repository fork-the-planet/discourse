# frozen_string_literal: true

require "badge_queries"

BadgeGrouping.seed do |g|
  g.id = BadgeGrouping::GettingStarted
  g.name = "Getting Started"
  g.default_position = 10
end

BadgeGrouping.seed do |g|
  g.id = BadgeGrouping::Community
  g.name = "Community"
  g.default_position = 11
end

BadgeGrouping.seed do |g|
  g.id = BadgeGrouping::Posting
  g.name = "Posting"
  g.default_position = 12
end

BadgeGrouping.seed do |g|
  g.id = BadgeGrouping::TrustLevel
  g.name = "Trust Level"
  g.default_position = 13
end

BadgeGrouping.seed do |g|
  g.id = BadgeGrouping::Other
  g.name = "Other"
  g.default_position = 14
end

# BUGFIX
DB.exec <<-SQL.squish
  UPDATE badges
     SET badge_grouping_id = -1
   WHERE NOT EXISTS (
            SELECT 1
              FROM badge_groupings g
             WHERE g.id = badge_grouping_id
         ) OR (id < 100 AND badge_grouping_id = #{BadgeGrouping::Other})
SQL

[
  [Badge::BasicUser, "Basic User", BadgeType::Bronze],
  [Badge::Member, "Member", BadgeType::Bronze],
  [Badge::Regular, "Regular", BadgeType::Silver],
  [Badge::Leader, "Leader", BadgeType::Gold],
].each do |id, name, type|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.badge_type_id = type
    b.query = BadgeQueries.trust_level(id)
    b.default_badge_grouping_id = BadgeGrouping::TrustLevel
    b.trigger = Badge::Trigger::TrustLevelChange
    # allow title for tl3 and above
    b.default_allow_title = id > Badge::Member
    b.default_icon = "user"
    b.system = true
  end
end

Badge.seed do |b|
  b.id = Badge::Reader
  b.name = "Reader"
  b.default_icon = "book-open-reader"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = BadgeQueries::Reader
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.auto_revoke = false
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::ReadGuidelines
  b.name = "Read Guidelines"
  b.default_icon = "file-lines"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = BadgeQueries::ReadGuidelines
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::UserChange
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstLink
  b.name = "First Link"
  b.default_icon = "link"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = BadgeQueries::FirstLink
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstQuote
  b.name = "First Quote"
  b.default_icon = "quote-right"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = BadgeQueries::FirstQuote
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstLike
  b.name = "First Like"
  b.default_icon = "heart"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = BadgeQueries::FirstLike
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostAction
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstFlag
  b.name = "First Flag"
  b.default_icon = "flag"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = false
  b.query = BadgeQueries::FirstFlag
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostAction
  b.auto_revoke = false
  b.system = true
end

[
  [Badge::Promoter, "Promoter", BadgeType::Bronze, 1, 0],
  [Badge::Campaigner, "Campaigner", BadgeType::Silver, 3, 1],
  [Badge::Champion, "Champion", BadgeType::Gold, 5, 2],
].each do |id, name, type, count, trust_level|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "user-plus"
    b.badge_type_id = type
    b.multiple_grant = false
    b.target_posts = false
    b.show_posts = false
    b.query = BadgeQueries.invite_badge(count, trust_level)
    b.default_badge_grouping_id = BadgeGrouping::Community
    # daily is good enough
    b.trigger = Badge::Trigger::None
    b.auto_revoke = true
    b.system = true
  end
end

Badge.seed do |b|
  b.id = Badge::FirstShare
  b.name = "First Share"
  b.default_icon = "share-nodes"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = BadgeQueries::FirstShare
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  # don't trigger for now, its too expensive
  b.trigger = Badge::Trigger::None
  b.system = true
end

[
  [Badge::NiceShare, "Nice Share", BadgeType::Bronze, 25],
  [Badge::GoodShare, "Good Share", BadgeType::Silver, 300],
  [Badge::GreatShare, "Great Share", BadgeType::Gold, 1000],
].each do |id, name, level, count|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "share-nodes"
    b.badge_type_id = level
    b.multiple_grant = true
    b.target_posts = true
    b.show_posts = true
    b.query = BadgeQueries.sharing_badge(count)
    b.default_badge_grouping_id = BadgeGrouping::Community
    # don't trigger for now, its too expensive
    b.trigger = Badge::Trigger::None
    b.system = true
  end
end

Badge.seed do |b|
  b.id = Badge::Welcome
  b.name = "Welcome"
  b.default_icon = "heart"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = BadgeQueries::Welcome
  b.default_badge_grouping_id = BadgeGrouping::Community
  b.trigger = Badge::Trigger::PostAction
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::Autobiographer
  b.name = "Autobiographer"
  b.default_icon = "user-pen"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.query = BadgeQueries::Autobiographer
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::UserChange
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::Editor
  b.name = "Editor"
  b.default_icon = "pen"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.query = BadgeQueries::Editor
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::WikiEditor
  b.name = "Wiki Editor"
  b.default_icon = "far-pen-to-square"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.query = BadgeQueries::WikiEditor
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

[
  [Badge::NicePost, "Nice Post", BadgeType::Bronze, false],
  [Badge::GoodPost, "Good Post", BadgeType::Silver, false],
  [Badge::GreatPost, "Great Post", BadgeType::Gold, false],
].each do |id, name, type, topic|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "reply"
    b.badge_type_id = type
    b.multiple_grant = true
    b.target_posts = true
    b.show_posts = true
    b.query = BadgeQueries.like_badge(Badge.like_badge_counts[id], topic)
    b.default_badge_grouping_id = BadgeGrouping::Posting
    b.trigger = Badge::Trigger::PostAction
    b.system = true
  end
end

[
  [Badge::NiceTopic, "Nice Topic", BadgeType::Bronze, true],
  [Badge::GoodTopic, "Good Topic", BadgeType::Silver, true],
  [Badge::GreatTopic, "Great Topic", BadgeType::Gold, true],
].each do |id, name, type, topic|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "file-signature"
    b.badge_type_id = type
    b.multiple_grant = true
    b.target_posts = true
    b.show_posts = true
    b.query = BadgeQueries.like_badge(Badge.like_badge_counts[id], topic)
    b.default_badge_grouping_id = BadgeGrouping::Posting
    b.trigger = Badge::Trigger::PostAction
    b.system = true
  end
end

Badge.seed do |b|
  b.id = Badge::Anniversary
  b.name = "Anniversary"
  b.default_icon = "cake-candles"
  b.badge_type_id = BadgeType::Silver
  b.default_badge_grouping_id = BadgeGrouping::Community
  b.query = nil
  b.trigger = Badge::Trigger::None
  b.auto_revoke = false
  b.system = true
  b.multiple_grant = true
end

[
  [Badge::PopularLink, "Popular Link", BadgeType::Bronze, 50],
  [Badge::HotLink, "Hot Link", BadgeType::Silver, 300],
  [Badge::FamousLink, "Famous Link", BadgeType::Gold, 1000],
].each do |id, name, level, count|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "link"
    b.badge_type_id = level
    b.multiple_grant = true
    b.target_posts = true
    b.show_posts = true
    b.query = BadgeQueries.linking_badge(count)
    b.default_badge_grouping_id = BadgeGrouping::Posting
    # don't trigger for now, its too expensive
    b.trigger = Badge::Trigger::None
    b.system = true
  end
end

[
  [Badge::Appreciated, "Appreciated", BadgeType::Bronze, 1, 20],
  [Badge::Respected, "Respected", BadgeType::Silver, 2, 100],
  [Badge::Admired, "Admired", BadgeType::Gold, 5, 300],
].each do |id, name, level, like_count, post_count|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "heart"
    b.badge_type_id = level
    b.query = BadgeQueries.liked_posts(post_count, like_count)
    b.default_badge_grouping_id = BadgeGrouping::Community
    b.trigger = Badge::Trigger::None
    b.auto_revoke = false
    b.system = true
  end
end

[
  [Badge::ThankYou, "Thank You", BadgeType::Bronze, 20, 10],
  [Badge::GivesBack, "Gives Back", BadgeType::Silver, 100, 100],
  [Badge::Empathetic, "Empathetic", BadgeType::Gold, 500, 1000],
].each do |id, name, level, count, ratio|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "heart"
    b.badge_type_id = level
    b.query = BadgeQueries.liked_back(count, ratio)
    b.default_badge_grouping_id = BadgeGrouping::Community
    b.trigger = Badge::Trigger::None
    b.auto_revoke = false
    b.system = true
  end
end

[
  [Badge::OutOfLove, "Out of Love", BadgeType::Bronze, 1],
  [Badge::HigherLove, "Higher Love", BadgeType::Silver, 5],
  [Badge::CrazyInLove, "Crazy in Love", BadgeType::Gold, 20],
].each do |id, name, level, count|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "heart"
    b.badge_type_id = level
    b.query = BadgeQueries.like_rate_limit(count)
    b.default_badge_grouping_id = BadgeGrouping::Community
    b.trigger = Badge::Trigger::None
    b.auto_revoke = false
    b.system = true
  end
end

Badge.seed do |b|
  b.id = Badge::FirstMention
  b.name = "First Mention"
  b.default_icon = "at"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = BadgeQueries::FirstMention
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstEmoji
  b.name = "First Emoji"
  b.default_icon = "face-smile"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = nil
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::None
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstOnebox
  b.name = "First Onebox"
  b.default_icon = "cube"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = nil
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::None
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::FirstReplyByEmail
  b.name = "First Reply By Email"
  b.default_icon = "envelope"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = true
  b.show_posts = true
  b.query = nil
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::None
  b.system = true
end

Badge.seed do |b|
  b.id = Badge::NewUserOfTheMonth
  b.name = "New User of the Month"
  b.default_icon = "medal"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = BadgeGrouping::GettingStarted
  b.trigger = Badge::Trigger::None
  b.system = true
end

[
  [Badge::Enthusiast, "Enthusiast", BadgeType::Bronze, 10],
  [Badge::Aficionado, "Aficionado", BadgeType::Silver, 100],
  [Badge::Devotee, "Devotee", BadgeType::Gold, 365],
].each do |id, name, level, days|
  Badge.seed do |b|
    b.id = id
    b.name = name
    b.default_icon = "far-eye"
    b.badge_type_id = level
    b.query = BadgeQueries.consecutive_visits(days)
    b.default_badge_grouping_id = BadgeGrouping::Community
    b.trigger = Badge::Trigger::None
    b.auto_revoke = false
    b.system = true
  end
end

Badge
  .where("NOT system AND id < 100")
  .each do |badge|
    new_id = [Badge.maximum(:id) + 1, 100].max
    old_id = badge.id
    badge.update_columns(id: new_id)
    UserBadge.where(badge_id: old_id).update_all(badge_id: new_id)
  end
