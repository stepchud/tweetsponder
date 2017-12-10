class Chat
  CHATS = {}

  FIRST_RESPONSE = {
    text: "Hello, this is 911 Automated Emergency for San Francisco.  Please select your Language.",
    buttons: [
      {title: "English", payload: "LANG_EN"},
      {title: "Spanish", payload: "LANG_ES"},
      {title: "Other", payload: "LANG_OTHER"}
    ]
  }

  NEED_RESPONSE = {
    text: "OK! What type of assistance do you need?",
    buttons: [
      {title: "I'm having an Emergency!", payload: "NEED_HELP"},
      {title: "I just need info.", payload: "NEED_INFO"},
      {title: "I want to talk to an Operator.", payload: "NEED_OPERATOR"}
    ]
  }

  attr_reader :sender_id

  def initialize sender_id, user
    @sender_id = sender_id
    current_chat ||= {
      user: user,
      messages:[]
    }
  end

  def current_chat
    CHATS[sender_id]
  end

  def add_message text, postback=nil
    messages << text
    puts "added message #{text} to user #{sender_id}, they have #{messages.count}"
    case postback
    when /^NEED_/
      puts "got need #{text}"
      current_chat[:need] = text
    when /^LANG_/
      puts "got lang #{text}"
      current_chat[:lang] = text
    when nil
      puts "not a postback"
    else
      puts 'UKNOWN POSTBACK RESPONSE'
    end
  end

  def messages
    current_chat[:messages]
  end

  def get_response
    response = if messages.count == 1
      FIRST_RESPONSE
    elsif current_chat[:need]
      {text: "Ok, please describe your #{current_chat[:need]} emergency."}
    elsif current_chat[:lang]
      NEED_RESPONSE
    else
      {text: "Thanks for telling us. We got your message (#{messages.last})"}
    end
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
