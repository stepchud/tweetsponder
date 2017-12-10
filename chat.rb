class Chat
  CHATS = {}

  RESPONSES = [
    {
      text: "Hello, this is 911 Automated Emergency for San Francisco.  Please select your Language.",
      buttons: [
        {title: "English", payload: "LANG_EN"},
        {title: "Spanish", payload: "LANG_ES"},
        {title: "Other", payload: "LANG_OTHER"}
      ]
    },
    {
      text: "OK! What type of assistance do you need?",
      buttons: [
        {title: "I'm having an Emergency!", payload: "NEED_HELP"},
        {title: "I just need info.", payload: "NEED_INFO"},
        {title: "I want to talk to an Operator.", payload: "NEED_OPERATOR"}
      ]
    }
  ]

  attr_reader :sender_id

  def initialize sender_id, user
    @sender_id = sender_id
    CHATS[sender_id] ||= {
      messages:[],
      user: user
    }
  end

  def add_message text
    messages << text
    puts "added message #{text} to user #{sender_id}, they have #{messages.count}"
  end

  def messages
    CHATS[sender_id][:messages]
  end

  def get_response
    response = RESPONSES[messages.count-1] || {text: "Thanks for telling us. We got your message (#{messages.last})"}
    formatted = format_response response
    puts formatted.to_json
    formatted
  end

  def format_response text:, buttons: []
    if buttons.empty?
      {
        recipient: {"id": sender_id},
        message: { text: text }
      }
    else
      {
        recipient: {"id": sender_id},
        message: {
          attachment: {
            type: "template",
            payload: {
              template_type: "button",
              text: text,
              buttons: buttons.map{|button| {type: "postback"}.merge(button) }
            }
          }
        }
      }
    end
  end
end
