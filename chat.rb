class Chat
  CHATS = {}

  attr_reader :sender_id

  def initialize sender_id
    @sender_id = sender_id
    CHATS[sender_id] ||= {messages:[]}
  end

  def add_message text
    messages << text
    puts "added message #{text} to user #{sender_id}, they have #{messages.count}"
  end

  def messages
    CHATS[sender_id][:messages]
  end
end
