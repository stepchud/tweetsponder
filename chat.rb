class Chat
  CHATS = {}

  RESPONSES = [
    {
      text: "Hello, this is 911 Automated Emergency for San Francisco.  Please select your Language.",
      buttons: [ "English", "Spanish", "Other" ]
    },
    {
      text: "OK! What type of assistance do you need?",
      buttons: [ "I'm having an Emergency!", "I just need info.", "I want to talk to an Operator." ]
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
    format_response response
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
              buttons: buttons
            }
          }
        }
      }
    end
  end
end
