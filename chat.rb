class Chat
  CHATS = {}

  RESPONSES = [
    {
      text: "Hello, this is 911 Automated Emergency for San Francisco.  Please select your Language.",
      buttons: [
        {text: "English", postback: "LANG_EN"},
        {text: "Spanish", postback: "LANG_ES"},
        {text: "Other", postback: "LANG_OTHER"}
      ]
    },
    {
      text: "OK! What type of assistance do you need?",
      buttons: [
        {text: "I'm having an Emergency!", postback: "NEED_HELP"},
        {text: "I just need info.", postback: "NEED_INFO"},
        {text: "I want to talk to an Operator.", postback: "NEED_OPERATOR"}
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
              buttons: buttons.map{|button| {type: "postback", title: button[:text], postback: button[:postback]} }
            }
          }
        }
      }
    end
  end
end
