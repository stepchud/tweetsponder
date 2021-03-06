class Chat
  CHATS = {}

  FIRST_RESPONSE = {
    text: "this is 911 Automated Emergency for San Francisco.  Please select your Language.",
    buttons: [
      {title: "English", payload: "LANG_EN"},
      {title: "Spanish", payload: "LANG_ES"},
      {title: "Other", payload: "LANG_OTHER"}
    ]
  }

  NEED_RESPONSE = {
    text: "OK! What can we do for you?",
    buttons: [
      {title: "I NEED HELP!", payload: "NEED_HELP"},
      {title: "I just need info.", payload: "NEED_INFO"},
      {title: "Talk to an Operator.", payload: "NEED_OPERATOR"}
    ]
  }

  HELP_RESPONSE = {
    text: "OK! What type of help do you need?",
    buttons: [
      {title: "MEDICAL 🚑 ", payload: "HELP_MEDICAL"},
      {title: "FIRE 🚒 ", payload: "HELP_FIRE"},
      {title: "POLICE 🚓 ", payload: "HELP_POLICE"}
    ]
  }

  attr_reader :sender_id

  def initialize sender_id, user
    @sender_id = sender_id
    CHATS[sender_id] ||= {
      user: user,
      messages:[]
    }
  end

  def current_chat
    CHATS[sender_id]
  end

  def current_user
    puts "current_user data #{current_chat[:user]}"
    [current_chat[:user]['first_name'], current_chat[:user]['last_name']].compact.join(' ')
  end

  def add_message data
    if data[:location]
      puts "got location: #{data[:location]}"
      current_chat[:location] = data[:location]
    elsif data[:postback]
      case data[:postback]
      when /^HELP_(\w+)/
        puts "got help: #{$1}"
        current_chat[:help] = $1
      when /^NEED_(\w+)/
        puts "got need #{$1}"
        current_chat[:need] = $1
      when /^LANG_/
        puts "got lang #{data[:text]}"
        current_chat[:lang] = data[:postback]
      when nil
        puts "not a postback"
      else
        puts 'UKNOWN POSTBACK RESPONSE'
      end
    elsif data[:phone_number]
      puts "got phone #{data[:phone_number]}"
      current_chat[:phone_number] = data[:phone_number]
    elsif current_chat[:phone_number]
      puts "got description #{data[:description]}"
      current_chat[:description] = data[:text]
    else
      messages << data[:text]
      puts "added message #{data[:text]} to user #{sender_id}, they have #{messages.count}"
    end

  end

  def messages
    current_chat[:messages]
  end

  def get_response
    response = if current_chat[:description]
      {text: "I have all the information I need. #{current_chat[:help].downcase.capitalize} help is on the way."}
    elsif current_chat[:phone_number]
      {text: "Got your phone number. Please describe your #{current_chat[:help].downcase} emergency."}
    elsif current_chat[:location]
      {text: "I found your location. Please send your phone number so the emergency crew can reach you when they arrive."}
    elsif current_chat[:help]
      {text: "In order to send help, I need your location. Please share your location by clicking the blue + and choosing location."}
    elsif current_chat[:need]
      HELP_RESPONSE
    elsif current_chat[:lang]
      NEED_RESPONSE
    else # first interaction
      greeting = FIRST_RESPONSE
      greeting[:text].prepend("Hello #{current_user}, ")
      greeting
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
