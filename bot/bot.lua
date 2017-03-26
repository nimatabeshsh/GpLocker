bot = dofile('/home/bot/gplocker/data/utils.lua')
json = dofile('/home/bot/gplocker/data/JSON.lua')
URL = require "socket.url"
serpent = require("serpent")
http = require "socket.http"
https = require "ssl.https"
redis = require('redis')
db = redis.connect('127.0.0.1', 6379)
BASE = '/home/bot/gplocker/bot/'
SUDO = 238773538 --sudo id
sudo_users = {238773538}
BOTS = 330614906 --bot id
bot_id = db:get(SUDO..'bot_id')
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- vardump(data)
  --vardump(arg)
end

  function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
------------------------------------------------------------
function is_master(msg) 
  local hash = db:sismember(SUDO..'masters:'..msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_bot(msg)
  if tonumber(BOTS) == 330614906 then
    return true
    else
    return false
    end
  end
  ------------------------------------------------------------
function is_owner(msg) 
  local hash = db:sismember(SUDO..'owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_mod(msg) 
  local hash = db:sismember(SUDO..'mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_allow(msg) 
  local hash = db:sismember(SUDO..'allow:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_mod(msg) or is_owner(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_banned(chat,user)
   local hash =  db:sismember(SUDO..'banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
  ------------------------------------------------------------
  function is_filter(msg, value)
  local hash = db:smembers(SUDO..'filters:'..msg.chat_id_)
  if hash then
    local names = db:smembers(SUDO..'filters:'..msg.chat_id_)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg) then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
  end
  ------------------------------------------------------------
function is_muted(chat,user)
   local hash =  db:sismember(SUDO..'mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
  	-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function priv(chat,user)
  local ohash = db:sismember(SUDO..'owners:'..chat,user)
  local mhash = db:sismember(SUDO..'mods:'..chat,user)
 if tonumber(SUDO) == tonumber(user) or mhash or ohash then
   return true
    else
    return false
    end
  end
  ------------------------------------------------------------
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید دیگر مدیران را اخراج کنید!</code>', 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
    end
  end
  ------------------------------------------------------------
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید دیگر مدیران را از گروه مسدود کنید!</code>', 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
  db:sadd(SUDO..'banned'..chat,user)
  local t = '🚫کاربر [<b>'..user..'</b>] بن شد😠'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t, 1, 'html')
  end
  end
  ------------------------------------------------------------
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید توانایی گفتگو در گروه را از دیگر مدیران سلب کنید!</code>', 'html')
    else
  db:sadd(SUDO..'mutes'..chat,user)
  local t = '⚠️کاربر [<b>'..user..' or '..usera..'</b>] در لیست سکوت به مدت نامحدود قرار گرفت🙂'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  end
  ------------------------------------------------------------
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'banned'..chat,user)
  local t = '☑️کاربر [<b>'..user..' or '..usera..'</b>]  از لیست بن خارج شد🙄'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  ------------------------------------------------------------
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'mutes'..chat,user)
  local t = '⚠️کاربر [<b>'..user..' or '..usera..'</b>]  از لیست سکوت خارج شد🙂'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  ------------------------------------------------------------
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end
------------------------------------------------------------
function user(msg,chat,text,user)
  entities = {}
  if text:match('<user>') and text:match('<user>') then
      local x = string.len(text:match('(.*)<user>'))
      local offset = x
      local y = string.len(text:match('<user>(.*)</user>'))
      local length = y
      text = text:gsub('<user>','')
      text = text:gsub('</user>','')
   table.insert(entities,{ID="MessageEntityMentionName", offset_=offset, length_=length, user_id_=user})
  end
    entities[0] = {ID='MessageEntityBold', offset_=0, length_=0}
return tdcli_function ({ID="SendMessage", chat_id_=chat, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_=entities}}, dl_cb, nil)
end
------------------------------------------------------------
function settings(msg,value,lock) 
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
  if value == 'file' then
      text = 'فیلتر-فایل'
   elseif value == 'keyboard' then
    text = 'فیلتر-درون.خطی(کیبرد شیشه ای)'
  elseif value == 'link' then
    text = 'قفل-ارسال لینک'
  elseif value == 'game' then
    text = 'انجام بازی های(انلاین)'
    elseif value == 'username' then
    text = 'ارسال یوزرنیم(@)'
   elseif value == 'pin' then
    text = 'قفل پین-کردن(پیام)'
    elseif value == 'photo' then
    text = 'فیلتر-تصاویر'
    elseif value == 'gif' then
    text = 'فیلتر-تصاویر-متحرک'
    elseif value == 'video' then
    text = 'فیلتر-ویدئو'
    elseif value == 'audio' then
    text = 'فیلتر-صدا(audio-voice)'
    elseif value == 'music' then
    text = 'فیلتر-آهنگ(MP3)'
    elseif value == 'text' then
    text = 'فیلتر-متن'
    elseif value == 'sticker' then
    text = 'ارسال-برچسب'
    elseif value == 'contact' then
    text = 'فیلتر-مخاطبین'
    elseif value == 'forward' then
    text = 'فیلتر-فوروارد'
    elseif value == 'persian' then
    text = 'فیلتر-گفتمان(فارسی)'
    elseif value == 'english' then
    text = 'فیلتر-گفتمان(انگلیسی)'
    elseif value == 'bot' then
    text = 'قفل ورود-ربات(API)'
    elseif value == 'tgservice' then
    text = 'فیلتر-پیغام-ورود،خروج افراد'
    else return false
    end
  if lock then
db:set(hash,true)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>*</b> <code>'..text..'</code> >  فعال شد.',1,'html')
    else
  db:del(hash)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>*</b> <code>'..text..'</code> >  غیرفعال شد.',1,'html')
end
end
------------------------------------------------------------
function is_lock(msg,value)
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
 if db:get(hash) then
    return true 
    else
    return false
    end
  end
------------------------------------------------------------
function trigger_anti_spam(msg,type)
  if type == 'kick' then
    kick(msg,msg.chat_id_,msg.sender_user_id_)
    end
  if type == 'ban' then
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '👤 كاربر  [<b>'..msg.sender_user_id_..'</b>] به دليل اسپم `مسدود (بن)` شد .', 1,'html')
      end
bot.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  db:sadd(SUDO..'banned'..msg.chat_id_,msg.sender_user_id_)
  end
	if type == 'mute' then
    if is_muted(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '👤 كاربر [<b>'..msg.sender_user_id_..'</b>] به دليل ارسال اسپم به ليست سكوت (ميوت) اضافه شد .', 1,'html')
      end
  db:sadd(SUDO..'mutes'..msg.chat_id_,msg.sender_user_id_)
	end
  end
function televardump(msg,value)
  local text = json:encode(value)
  bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 'html')
  end
------------------------------------------------------------
function run(msg,data)
   --vardump(data)
  --televardump(msg,data)

    if msg then
            db:incr(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
      if msg.send_state_.ID == "MessageIsSuccessfullySent" then
      return false 
      end
      end
    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
    local text = msg.content_.text_
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text
		end
    --------- messages type -------------------
    if msg.content_.ID == "MessageText" then
      msg_type = 'text'
    end
    if msg.content_.ID == "MessageChatAddMembers" then
      msg_type = 'add'
    end
    if msg.content_.ID == "MessageChatJoinByLink" then
      msg_type = 'join'
    end
    if msg.content_.ID == "MessagePhoto" then
      msg_type = 'photo'
      end
    -------------------------------------------
    if msg_type == 'text' and text then
      if text:match('^[/!]') then
      text = text:gsub('^[/!]','')
      end
    end
  
     if text then
      if not db:get(SUDO..'bot_id') then
         function cb(a,b,c)
         db:set(SUDO..'bot_id',b.id_)
         end
      bot.getMe(cb)
      end
    end
  ------------------------------------------------------------
    if chat_type == 'super' then
    NUM_MSG_MAX = 5
    if db:get(SUDO..'floodmax'..msg.chat_id_) then
      NUM_MSG_MAX = db:get(SUDO..'floodmax'..msg.chat_id_)
      end
      TIME_CHECK = 3
    if db:get(SUDO..'floodtime'..msg.chat_id_) then
      TIME_CHECK = db:get(SUDO..'floodtime'..msg.chat_id_)
      end
    if text and text:match('test (%d+)') then
     
      end
    -- check flood
    if db:get(SUDO..'settings:flood'..msg.chat_id_) then
    if not is_mod(msg) then
      local post_count = 'user:' .. msg.sender_user_id_ .. ':floodc'
      local msgs = tonumber(db:get(post_count) or 0)
      if msgs > tonumber(NUM_MSG_MAX) and not msg.content_.ID == "MessageChatAddMembers" then
       local type = db:get(SUDO..'settings:flood'..msg.chat_id_)
        trigger_anti_spam(msg,type)
      end
      db:setex(post_count, tonumber(TIME_CHECK), msgs+1)
    end
    end
-- save pin message id
  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 db:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 db:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
 -- check filters
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
-- check settings
    
     -- lock tgservice
      if is_lock(msg,'tgservice') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
    -- lock pin
    if is_owner(msg) then else
      if is_lock(msg,'pin') then
        if msg.content_.ID == 'MessagePinMessage' then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>قفل پیغام پین شده فعال است</code>\n<code>شما دارای مقام نمیباشید و امکان پین کردن پیامی را ندارید</code>',1, 'html')
      bot.unpinChannelMessage(msg.chat_id_)
          local PinnedMessage = db:get(SUDO..'pinned'..msg.chat_id_)
          if PinnedMessage then
             bot.pinChannelMessage(msg.chat_id_, tonumber(PinnedMessage), 0)
            end
          end
        end
      end
      if is_mod(msg) then
        else
        -- lock link
        if is_lock(msg,'link') then
          if text then
        if msg.content_.entities_ and msg.content_.entities_[0] and msg.content_.entities_[0].ID == 'MessageEntityUrl' or msg.content_.text_.web_page_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:match("[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or text:match("[Tt].[Mm][Ee]/")
            if is_link then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock username
        if is_lock(msg,'username') then
          if text then
       local is_username = text:match("@[%a%d]")
        if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_username = text:match("@[%a%d]")
            if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock sticker 
        if is_lock(msg,'sticker') then
          if msg.content_.ID == 'MessageSticker' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
end
          end
        -- lock forward
        if is_lock(msg,'forward') then
          if msg.forward_info_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
          end
        -- lock photo
        if is_lock(msg,'photo') then
          if msg.content_.ID == 'MessagePhoto' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock file
        if is_lock(msg,'file') then
          if msg.content_.ID == 'MessageDocument' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
      -- lock file
        if is_lock(msg,'keyboard') then
          if msg.reply_markup_ and msg.reply_markup_.ID == 'ReplyMarkupInlineKeyboard' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
      -- lock game
        if is_lock(msg,'game') then
          if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock music 
        if is_lock(msg,'music') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock voice 
        if is_lock(msg,'audio') then
          if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock gif
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end 
        -- lock contact
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock video 
        if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
           end
          end
        -- lock text 
        if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock persian 
        if is_lock(msg,'persian') then
          if text:match('[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_persian = text:match("[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]")
            if is_persian then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock english 
        if is_lock(msg,'english') then
          if text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_english = text:match("[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]")
            if is_english then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock bot
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
              end
            end
          end
      end

-- check mutes
      local muteall = db:get(SUDO..'muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) and not is_allow(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
-- check bans
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر مورد نظر مسدود نمیباشد!',1, 'html')
      end
-- welcome
    local status_welcome = (db:get(SUDO..'status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
			    if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) then
     function wlc(extra,result,success)
        if db:get(SUDO..'welcome:'..msg.chat_id_) then
        t = db:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش آمدید!'
        end
      local t = t:gsub('{name}',result.first_name_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
          end
        bot.getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      if db:get(SUDO..'welcome:'..msg.chat_id_) then
        t = db:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش آمدید!'
        end
      local t = t:gsub('{name}',msg.content_.members_[0].first_name_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
      end
        end
          end
      end
      -- locks
    if text and is_owner(msg) then
      local lock = text:match('^lock pin$')
       local unlock = text:match('^unlock pin$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end
      end 
    if text and is_mod(msg) then
       local lock = text:match('^lock (.*)$')
       local unlock = text:match('^unlock (.*)$')
      local pin = text:match('^lock pin$') or text:match('^unlock pin$')
      if pin and is_owner(msg) then
        elseif pin and not is_owner(msg) then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>انجام این دستور برای شما مجاز نمیباشد!</code>',1, 'html')
        elseif lock then
          settings(msg,lock,'lock')
        elseif unlock then
          settings(msg,unlock)
        end
        end
    
 -- lock flood settings
    if text and is_owner(msg) then
       local hash = SUDO..'settings:flood'..msg.chat_id_
      if text == '[Ll]ock flood kick' then
      db:set(hash,'kick') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✅ `قفل ارسال پیام مکرر فعال گردید! `\n 🔸عملكرد : _اخراج(كيك)_',1, 'html')
      elseif text == '[Ll]ock flood ban' then
        db:set(hash,'ban') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✅ `قفل ارسال پیام مکرر فعال گردید! `\n 🔸عملكرد : _مسدود-سازی(بن)_',1, 'html')
        elseif text == '[Ll]ock flood mute' then
        db:set(hash,'mute') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✅ `قفل ارسال پیام مکرر فعال گردید! `\n 🔸عملكرد : _ساكت(ميوت)_',1, 'html')
        elseif text == '[Uu]nlock flood' then
        db:del(hash) 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '🔓حساسیت به پیام های رگباری غیرفعال شد❌',1, 'html')
            end
          end
       
        -- sudo
    if text then
      if is_sudo(msg) then
        if text == '[Ll]eave' and is_sudo(msg) then
		    bot.sendMessage(msg.chat_id_, msg.id_, 1, '⚠️به دستور ادمین ربات از گروه خارج می‌شود🙄',1, 'html')
            bot.changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
          end
        if text == '[Ss]etowner' and is_owner(msg) then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '🌟کاربر [<b>'..user..'</b>] مالک گروه شد😊', 1, 'html')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^[Ss]etowner (%d+)') and is_owner(msg) then
          local user = text:match('setowner (%d+)')
          db:sadd(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '🌟کاربر [<b>'..user..'</b>] مالک گروه شد😊', 1, 'html')
      end
        if text == '[Dd]eowner' and is_owner(msg) then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️ کاربر [<b>'..result.sender_user_id_..'</b>] از لیست مالکان گروه حذف شد☹️', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text and text:match('^[Dd]eowner (%d+)') and is_owner(msg) then
          local user = text:match('deowner (%d+)')
         db:srem(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️ کاربر [<b>'..result.sender_user_id_..'</b>] از لیست مالکان گروه حذف شد☹️', 1, 'html')
      end
        end
      if text == '[Cc]lean ownerlist' and is_sudo(msg) then
        db:del(SUDO..'owners:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'☑️ لیست مالکین گروه پاک شد', 1, 'html')
        end
      --------------------------master--------------------------
	   if text == '[Ss]etadmin' and is_owner(msg) then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'masters:'..result.sender_user_id_)
        local master = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '✅کاربر  [<b>'..master..'</b>] به لیست ادمین های من افزوده شد🙂', 1, 'html')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^[Ss]etadmin (%d+)') and is_owner(msg) then
          local master = text:match('setadmin (%d+)')
          db:sadd(SUDO..'masters:'..master)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✅کاربر  [<b>'..master..'</b>] به لیست ادمین های من افزوده شد🙂', 1, 'html')
      end
        if text == '[Dd]eladmin' and is_owner(msg) then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'masters:'..result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✅کاربر  [<b>'..master..'</b>] به لیست ادمین های من افزوده شد🙂', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        if text and text:match('^[Dd]eladmin (%d+)') and is_owner(msg) then
          local master = text:match('deladmin (%d+)')
         db:srem(SUDO..'masters:'..master)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️کاربر [<b>'..master..'</b>] از لیست ادمین های من خارج شد🙁', 1, 'html')
      end
        end
	  ---############################################--
	   if text == '[Rr]eload' and is_sudo(msg) then
       dofile('bot.lua') 
 bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>✔️ ربات بروزرساني شد . . . !</code>', 1, 'html')
            end
	    if text == '[Ss]tats' and is_sudo(msg) then
    local gps = db:scard("botgp")
	local users = db:scard("usersbot")
    local allmgs = db:get("allmsg")

					bot.sendMessage(msg.chat_id_, msg.id_, 1, '>آمار ربات:\n\nتعداد کل گروه ها: [*'..gps..'*]\nتعداد پی وی ها: [*'..users..'*]\nتعداد پیام ها: [*'..allmgs..'*]', 1, 'html')
	end
	  --###########################################--
      -- owner
     if is_owner(msg) then
        if text == '[Cc]lean bots' or text == 'پاكسازي ربات ها' and is_mod(msg) then
      local function cb(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          kick(msg,msg.chat_id_,bots[i].user_id_)
          end
        end
       bot.channel_get_bots(msg.chat_id_,cb)
       end
          if text and text:match('^[Ss]etlinktext (.*)') and is_mod(msg) then
            local link = text:match('[Ss]etlinktext (.*)')
            db:set(SUDO..'grouplink'..msg.chat_id_, link)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'🌐 متن لینک تغییر یافت🤓', 1, 'html')
            end
          if text == '[Rr]emlink' and is_mod(msg) then
            db:del(SUDO..'grouplink'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'لینک تنظیم شده با موفقیت بازنشانی گردید.', 1, 'html')
            end
            if text and text:match('^[Ss]etname (.*)') and is_owner(msg) then
            local name = text:match('^[Ss]etname (.*)')
            bot.changeChatTitle(msg.chat_id_, name)
            end
        if text == '[Ww]elcome on' and is_mod(msg) then
          db:set(SUDO..'status:welcome:'..msg.chat_id_,'enable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅خوشامدگویی فعال شد😉', 1, 'html')
          end
        if text == '[Ww]elcome off' and is_mod(msg) then
          db:set(SUDO..'status:welcome:'..msg.chat_id_,'disable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'❌خوشامدگویی غیرفعال شد😶', 1, 'html')
          end
        if text and text:match('^[Ss]etwelcometext (.*)') or text:match('^تنظیم متن خوشامدگویی (.*)') and is_mod(msg) then
          local welcome = text:match('^setwelcometext (.*)')
          db:set(SUDO..'welcome:'..msg.chat_id_,welcome)
          local t = '🔱 متن خوشامدگویی به {'..welcome..'} تغییر کرد😁'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
        if text == '[Dd]elete welcome' then
          db:del(SUDO..'welcome:'..msg.chat_id_,welcome)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅ پیغام خوش آمدگویی بازنشانی گردید و به حالت پیشفرض تنظیم شد.', 1, 'html')
          end
        if text == 'لیست مالکان' or text == '[Oo]wnerlist' then
          local list = db:smembers(SUDO..'owners:'..msg.chat_id_)
          local t = '🤡 لیست مالکین گروه: \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nبرای مشاهده کاربر از دستور زیر استفاده کنید \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<code>>لیست مالکان گروه خالی میباشد!</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    if text == '[Pp]romote' or text == 'ترفیع' and is_owner(msg) then
        function prom_reply(extra, result, success)
        db:sadd(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '⭐️کاربر [<b>'..user..'</b>] مدیر شد😊', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^[Pp]romote @(.*)') or text:match('^ترفیع @(.*)') and is_owner(msg) then
        local username = text:match('^[Pp]romote @(.*)')
		local usernamea = text:match('^ترفیع @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        db:sadd(SUDO..'mods:'..msg.chat_id_,result.id_)
        text ='⭐️کاربر [<b>'..result.id_..'</b>] مدیر شد😊'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,promreply)
		bot.resolve_username(usernamea,promreply)
        end
        if text and text:match('^[Pp]romote @(.*)') or text:match('^ترفیع @(.*)') and is_owner(msg) then
          local user = text:match('[Pp]romote (%d+)')
		  local usera = text:match('^ترفیع @(.*)')
          db:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '⭐️کاربر [<b>'..user..' or '..usera..'</b>] مدیر شد😊', 1, 'html')
      end
        if text == '[Dd]emote' or text == 'عزل' and is_owner(msg) then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️کاربر [<b>'..result.sender_user_id_..'</b>] از مدیریت برکنار شد☹️', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^[Dd]emote @(.*)') or text:match('^عزل @(.*)') and is_owner(msg) then
        local username = text:match('^[Dd]emote @(.*)')
		local usernamea = text:match('^عزل @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        db:srem(SUDO..'mods:'..msg.chat_id_,result.id_)
        text = '☑️کاربر [<b>'..result.id_..'</b>] از مدیریت برکنار شد☹️'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,demreply)
		bot.resolve_usernamea(username,demreply)
        end
        if text and text:match('^[Pp]romote (%d+)') or text:match('^ترفيع (%d+)') and is_owner(msg) then
          local user = text:match('[Pp]romote (%d+)')
		  local usera = text:match('ترفيع (%d+)')
          db:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '⭐️کاربر [<b>'..user..' or '..usera..'</b>] مدیر شد😊', 1, 'html')
      end
        if text and text:match('^[Dd]emote @(.*)') or text:match('^عزل @(.*)') and is_owner(msg) then
          local user = text:match('[Dd]emote (%d+)')
		  local usera = text:match('عزل (%d+)')
         db:srem(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️کاربر [<b>'..user..' or '..usera..'</b>] از مدیریت برکنار شد☹️', 1, 'html')
      end
  end
      end
-- allow
    if text == '[Aa]llow' or text == 'مجاز' and is_owner(msg) then
        function allow_reply(extra, result, success)
        db:sadd(SUDO..'allow:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '✨کاربر [<b>'..user..'</b>] مجاز شد😊', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),allow_reply)  
          end
        end
        if text:match('^[Aa]llow @(.*)') or text:match('^مجاز @(.*)') and is_owner(msg) then
        local username = text:match('^[Aa]llow @(.*)')
		local usernamea = text:match('^مجاز @(.*)')
        function allowreply(extra,result,success)
          if result.id_ then
        db:sadd(SUDO..'allow:'..msg.chat_id_,result.id_)
        text ='✨کاربر [<b>'..result.id_..'</b>] مجاز شد😊'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,allowreply)
		bot.resolve_username(usernamea,allowreply)
        end
        if text and text:match('^[Aa]llow @(.*)') or text:match('^مجاز @(.*)') and is_owner(msg) then
          local user = text:match('[Aa]llow (%d+)')
		  local usera = text:match('^مجاز @(.*)')
          db:sadd(SUDO..'allow:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✨کاربر [<b>'..user..' or '..usera..'</b>] مجاز شد😊', 1, 'html')
      end
        if text == '[Uu]nallow' or text == 'رفع مجاز' and is_owner(msg) then
        function allow_reply(extra, result, success)
        db:srem(SUDO..'allow:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️کاربر [<b>'..result.sender_user_id_..'</b>] از لیست مجاز خارج شد☹️', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^[Uu]nallow @(.*)') or text:match('^رفع مجاز @(.*)') and is_owner(msg) then
        local username = text:match('^[Uu]nallow @(.*)')
		local usernamea = text:match('^رفع مجاز @(.*)')
        function unallowreply(extra,result,success)
          if result.id_ then
        db:srem(SUDO..'allow:'..msg.chat_id_,result.id_)
        text = '☑️کاربر [<b>'..result.id_..'</b>] از لیست مجاز خارج شد☹️'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,unallowreply)
		bot.resolve_usernamea(username,unallowreply)
        end
        if text and text:match('^[Aa]llow (%d+)') or text:match('^مجاز (%d+)') and is_owner(msg) then
          local user = text:match('[Aa]llow (%d+)')
		  local usera = text:match('مجاز (%d+)')
          db:sadd(SUDO..'allow:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✨کاربر [<b>'..user..' or '..usera..'</b>] مجاز شد😊', 1, 'html')
      end
        if text and text:match('^[Uu]nallow @(.*)') or text:match('^رفغ مجاز @(.*)') and is_owner(msg) then
          local user = text:match('[Uu]nallow (%d+)')
		  local usera = text:match('رفع مجاز (%d+)')
         db:srem(SUDO..'allow:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '☑️کاربر [<b>'..user..' or '..usera..'</b>] از لیست مجاز خارج شد☹️', 1, 'html')
      end
  end
-- mods
    if is_mod(msg) then
      local function getsettings(value)
        if value == 'muteall' then
        local hash = db:get(SUDO..'muteall'..msg.chat_id_)
        if hash then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'welcome' then
        local hash = db:get(SUDO..'welcome:'..msg.chat_id_)
        if hash == 'enable' then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'spam' then
        local hash = db:get(SUDO..'settings:flood'..msg.chat_id_)
        if hash then
             if db:get(SUDO..'settings:flood'..msg.chat_id_) == 'kick' then
         return '<code>User-kick</code>'
              elseif db:get(SUDO..'settings:flood'..msg.chat_id_) == 'ban' then
              return '<code>User-ban</code>'
							elseif db:get(SUDO..'settings:flood'..msg.chat_id_) == 'mute' then
              return '<code>Mute</code>'
              end
          else
          return '<code>مجاز</code>'
          end
        elseif is_lock(msg,value) then
          return '<code>غیرمجاز</code>'
          else
          return '<code>مجاز</code>'
          end
        end
        ---------------------------------------------------
      if text == '[Ss]ettings' then
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 318385937,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(msg.chat_id_),
      offset_ = 0
    }, inline, nil)
       end
	   --[[if text == 'muteslist' then
        local text = '><b>Group-Filterlist:</b>\n<b>----------------</b>\n'
        ..'><code>Filter-Photo:</code> |'..getsettings('photo')..'|\n'
        ..'><code>Filter-Video:</code> |'..getsettings('video')..'|\n'
        ..'><code>Filter-Audio:</code> |'..getsettings('voice')..'|\n'
        ..'><code>Filter-Gifs:</code> |'..getsettings('gif')..'|\n'
        ..'><code>Filter-Music:</code> |'..getsettings('music')..'|\n'
        ..'><code>Filter-File:</code> |'..getsettings('file')..'|\n'
        ..'><code>Filter-Text:</code> |'..getsettings('text')..'|\n'
        ..'><code>Filter-Contacts:</code> |'..getsettings('contact')..'|\n'
        ..'><code>Filter-Forward:</code> |'..getsettings('forward')..'|\n'
        ..'><code>Filter(Inline-mod):</code> |'..getsettings('game')..'|\n'
        ..'><code>Filter-Service(Join):</code> |'..getsettings('tgservice')..'|\n'
        ..'><code>Mute-Chat:</code> |'..getsettings('muteall')..'|\n'
        bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, '')
       end]]
      if text and text:match('^[Ss]etfloodmsg (%d+)$') and is_mod(msg) then
          db:set(SUDO..'floodmax'..msg.chat_id_,text:match('[Ss]etfloodmsg (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'🛡حساسیت فلود روی [<b>'..text:match('[Ss]etfloodmsg (.*)')..'</b>] پیام تنظیم شد🤓', 1, 'html')
        end
        if text and text:match('^[Ss]etfloodtime (%d+)$') and is_mod(msg) then
          db:set(SUDO..'floodtime'..msg.chat_id_,text:match('[Ss]etfloodtime (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'🛡حساسیت فلود روی [<b>'..text:match('[Ss]etfloodtime (.*)')..'</b>] ثانیه تنظیم شد🤓', 1, 'html')
        end
        if text == 'link' then
          local link = db:get(SUDO..'grouplink'..msg.chat_id_) 
          if link then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>لینک گروه به گروه:</code> \n'..link, 1, 'html')
            else
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '📌 لینک ورود به گروه تنظیم نشده است\n🙊ثبت لینک جدید با دستور <code>/setlink link</code> امكان پذير است . . .!', 1, 'html')
            end
          end
        if text == '[Mm]ute all' and is_mod(msg) then
          db:set(SUDO..'muteall'..msg.chat_id_,true)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>فیلتر تمامی گفتگو ها فعال گردید!</code>', 1, 'html')
          end
        if text and text:match('^[Ll]ockgp (%d+)[mhs]') or text and text:match('^[Ll]ockgp (%d+) [mhs]') and is_mod(msg) then
          local matches = text:match('^[Ll]ockgp (.*)')
          if matches:match('(%d+)h') then
          time_match = matches:match('(%d+)h')
          time = time_match * 3600
          end
          if matches:match('(%d+)s') then
          time_match = matches:match('(%d+)s')
          time = time_match
          end
          if matches:match('(%d+)m') then
          time_match = matches:match('(%d+)m')
          time = time_match * 60
          end
          local hash = SUDO..'muteall'..msg.chat_id_
          db:setex(hash, tonumber(time), true)
          bot.sendMessage(msg.chat_id_, msg.id_, 1, '⏰ گروه به مدت [<b>'..time..'</b>] قفل شد .\n⚠️چت ممنوع', 1, 'html')
          end
        if text == '[Uu]lock gp' and is_mod(msg) then
          db:del(SUDO..'muteall'..msg.chat_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '✔️ فیلتر تمامی گفتگو ها غیرفعال گردید!', 1, 'html')
          end
        if text == '[Ll]ockgp time' and is_mod(msg) then
          local status = db:ttl(SUDO..'muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = '✳️ زمانی برای آزاد شدن چت تعییین نشده است !'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
            else
          t = '⏰ [<b>'..status..'</b>] زمان مانده تا گروه آزاد شود . . .'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
          end
    if text == 'لیست بن' or text == '[Bb]anlist' and is_mod(msg) then
          local list = db:smembers(SUDO..'banned'..msg.chat_id_)
          local t = '🚫لیست بن شده ها: \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code>\n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>لیست افراد مسدود شده از گروه خالی میباشد.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == '[Cc]lean banlist' or text == 'پاکسازی لیست بن' and is_mod(msg) then
        db:del(SUDO..'banned'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅لیست بن پاک شد🙂', 1, 'html')
        end
        if text == '[Mm]utelist' or text == 'لیست سکوت' and is_mod(msg) then
          local list = db:smembers(SUDO..'mutes'..msg.chat_id_)
          local t = '💢لیست سکوت: \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = 'لیست افراد میوت شده خالی است !'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end      
      if text == '[Cc]lean mutelist' or text == 'پاکسازی لیست سکوت' and is_mod(msg) then
        db:del(SUDO..'mutes'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅لیست سکوت پاک شد🙁', 1, 'html')
        end
      if text == '[Kk]ick' and tonumber(msg.reply_to_message_id_) > 0 and is_mod(msg) then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
      if text and text:match('^[Kk]ick (%d+)') and is_mod(msg) then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
        end
      if text and text:match('^[Kk]ick @(.*)') then
        local username = text:match('kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,kick_username)
        end
        if text == '[Bb]an' or text == 'بن' and tonumber(msg.reply_to_message_id_) > 0 and is_mod(msg) then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
      if text and text:match('^[Bb]an (%d+)') or text:match('^بن (%d+)') and is_mod(msg) then
        ban(msg,msg.chat_id_,text:match('ban (%d+)'))
		ban(msg,msg.chat_id_,text:match('بن (%d+)'))
        end
      if text and text:match('^[Bb]an (%d+)') or text:match('^بن (%d+)') and is_mod(msg) then
        local username = text:match('ban @(.*)')
		local usernamea = text:match('بن @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,banusername)
        end
      if text == '[Uu]nban' or text == 'انبن' and tonumber(msg.reply_to_message_id_) > 0 and is_mod(msg) then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
      if text and text:match('^[Uu]nban (%d+)') or text:match('^انبن (%d+)') and is_mod(msg) then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
		unban(msg,msg.chat_id_,text:match('انبن (%d+)'))
        end
      if text and text:match('^[Uu]nban (%d+)') or text:match('^انبن (%d+)') and is_mod(msg) then
        local username = text:match('unban @(.*)')
		local usernamea = text:match('انبن @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unbanusername)
        end
        if text == '[Mm]ute' or text == 'سكوت' and tonumber(msg.reply_to_message_id_) > 0 and is_mod(msg) then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
      if text and text:match('^[Mm]ute (%d+)') or text:match('^سكوت (%d+)') and is_mod(msg) then
        mute(msg,msg.chat_id_,text:match('[Mm]ute (%d+)'))
		mute(msg,msg.chat_id_,text:match('سكوت (%d+)'))
        end
      if text and text:match('^[Mm]ute (%d+)') or text:match('^سكوت (%d+)') and is_mod(msg) then
        local username = text:match('[Mm]ute @(.*)')
		local usernamea = text:match('سكوت @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,muteusername)
        end
      if text == '[Uu]nmute' or text == 'رفع سكوت' and tonumber(msg.reply_to_message_id_) > 0 and is_mod(msg) then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
      if text and text:match('^[Uu]nmute (%d+)') or text:match('^رفع سكوت (%d+)') and is_mod(msg) then
        unmute(msg,msg.chat_id_,text:match('[Uu]nmute (%d+)'))
		unmute(msg,msg.chat_id_,text:match('رفع سكوت (%d+)'))
        end
     if text and text:match('^[Uu]nmute (%d+)') or text:match('^رفع سكوت (%d+)') and is_mod(msg) then
        local username = text:match('[Uu]nmute @(.*)')
		local usernamea = text:match('رفع سكوت @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unmuteusername)
        end
         if text == '[Ii]nvite' and tonumber(msg.reply_to_message_id_) > 0 and is_mod(msg) then
        function inv_by_reply(extra, result, success)
        bot.addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
      if text and text:match('^[Ii]nvite (%d+)') and is_mod(msg) then
        bot.addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text and text:match('^[Ii]nvite @(.*)') and is_mod then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        bot.addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,invite_username)
        end
    if text == '[Mm]odlist' or text == 'لیست مالکان' and is_mod(msg) then
          local list = db:smembers(SUDO..'mods:'..msg.chat_id_)
          local t = '✨ لیست مالکان گروه \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>مدیریت برای این گروه ثبت نشده است.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == '[Cc]lean modlist' or text == 'پاکسازی لیست مدیران' and is_owner(msg) then
        db:del(SUDO..'mods:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅لیست مدیران گروه پاک شد🙁', 1, 'html')
        end
		if text == '[Aa]llowlist' or text == 'ليست مجاز' and is_mod(msg) then
          local list = db:smembers(SUDO..'allow:'..msg.chat_id_)
          local t = '💫لیست کاربران مجاز: \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>مدیریت برای این گروه ثبت نشده است.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == '[Cc]lean allowlist' or text == 'پاکسازی لیست مجاز' and is_owner(msg) then
        db:del(SUDO..'allow:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅لیست کاربران مجاز پاک شد🙁', 1, 'html')
        end
      if text and text:match('^[Ff]ilter +(.*)') or text:match('^فیلتر +(.*)') and is_mod(msg) then
        local w = text:match('^[Ff]ilter +(.*)')
		local wa = text:match('^فیلتر +(.*)')
         db:sadd(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'☑️کلمه " '..w..' or '..wa..'" در لیست فیلتر قرار گرفت🙂', 1, 'html')
       end
      if text and text:match('^[Uu]nfilter +(.*)') or text:match('^رفع فیلتر +(.*)') and is_mod(msg) then
        local w = text:match('^[Uu]nfilter +(.*)')
		local w = text:match('^رفع فیلتر +(.*)')
         db:srem(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'🔘کلمه " '..w..' or '..wa..'" از لیست فیلتر خارج شد🙂', 1, 'html')
       end
      if text == '[Cc]lean filterlist' or text == 'پاکسازی لیست فیلتر' and is_mod(msg) then
        db:del(SUDO..'filters:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'✅لیست کلمات فیلتر شده پاک شد🙂', 1, 'html')
        end
      if text == '[Aa]dminlist' or text == 'لیست ادمین ها' and is_mod(msg) then
        local function cb(extra,result,success)
        local list = result.members_
           local t = '<code>>لیست ادمین های گروه:</code>\n\n'
          local n = 0
            for k,v in pairs(list) do
           n = (n + 1)
              t = t..n.." - "..v.user_id_.."\n"
                    end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>', 1, 'html')
          end
       bot.channel_get_admins(msg.chat_id_,cb)
      end
      if text == '[Ff]ilterlist' or text == 'لیست فیلتر' and is_mod(msg) then
          local list = db:smembers(SUDO..'filters:'..msg.chat_id_)
          local t = '⭕️لیست کلمات فیلتر شده: \n\n'
          for k,v in pairs(list) do
          t = t..k.." - "..v.."\n" 
          end
          if #list == 0 then
          t = '<code>>لیست کلمات فیلتر شده خالی میباشد</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    local msgs = db:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
    if msg_type == 'text' then
        if text then
      if text:match('^[Ww]hois @(.*)') and is_mod(msg) then
        local username = text:match('^whois @(.*)')
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '<code>شناسه:</code> [<b>'..result.id_..'</b>]\n<code>تعداد پیام های ارسالی:</code> [<b>'..(db:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.id_) or 0)..'</b>]'
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,id_by_username)
        end
          if text == '[Ii]d' then
            if tonumber(msg.reply_to_message_id_) == 0 then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه-گروه</code>: {<b>'..msg.chat_id_..'</b>}', 1, 'html')
          end
            end
			if text == '[Pp]in' and is_mod(msg) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   bot.sendMessage(msg.chat_id_, msg.reply_to_message_id_, 1, "<code>>پیام مورد نظر شما پین شد.</code>", 1, 'html')
   end
			 if text == 'bot' then
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>BOT Online!</b>', 1, 'html')
      end

          end
        end
      end
   -- member
   if text == '[Pp]ing' or text == 'پینگ' then
          local a = {"انلاینم🙂","انلاينم داداچ 😐✔️","انلاينم باو ☺️✅"}
          bot.sendMessage(msg.chat_id_, msg.id_, 1,''..a[math.random(#a)]..'', 1, 'html')
      end
	  db:incr("allmsg")
	  if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not db:sismember("botgp",msg.chat_id_) then  
            db:sadd("botgp",msg.chat_id_)
			 -- db:incrby("g:pa")
        end
        elseif id:match('^(%d+)') then
        if not db:sismember("usersbot",msg.chat_id_) then
            db:sadd("usersbot",msg.chat_id_)
			--db:incrby("pv:mm")
        end
        else
        if not db:sismember("botgp",msg.chat_id_) then
            db:sadd("botgp",msg.chat_id_)
			 -- db:incrby("g:pa")
        end
     end
    end
	  if text == 'number' then
         local number = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","43","45","46","47","48","49","50"}  
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>Your Random Number:</b>\n [<code>'..number[math.random(#number)]..'</code>]', 1, 'html')
      end
    if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
       if text == "[Mm]e" then
         local msgs = db:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه:</code> [<b>'..msg.sender_user_id_..'</b>]\n<code>تعداد پیام ها:</code> [<b>'..msgs..'</b>]', 1, 'html')
      end
end
  
  
  -- help 
  if text and text == '[Hh]elp' then
    if is_sudo(msg) then
help = [[متن راهنمای مالک ربات ثبت نشده است.]]

  elseif is_owner(msg) then
    help = [[
	<code>>راهنمای مالکین گروه(اصلی-فرعی)</code>

*<b>[/#!]settings</b> --<code>دریافت تنظیمات گروه</code>
*<b>[/#!]setrules</b> --<code>تنظیم قوانین گروه</code>
*<b>[/#!]modset</b> @username|reply|user-id --<code>تنظیم مالک فرعی جدید برای گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]moddem</b> @username|reply|user-id --<code>حذف مالک فرعی از گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]ownerlist</b> --<code>دریافت لیست مدیران اصلی</code>
*<b>[/#!]managers</b> --<code>دریافت لیست مدیران فرعی گروه</code>
*<b>[/#!]setlink</b> <code>link</code> <code>{لینک-گروه} --تنظیم لینک گروه</code>
*<b>[/#!]link</b> <code>دریافت لینک گروه</code>
*<b>[/#!]kick</b> @username|reply|user-id <code>اخراج کاربر با ریپلی|یوزرنیم|شناسه</code>
<b>-------------------------------</b>
<code>>راهنمای بخش حذف ها</code>
*<b>[/#!]delete managers</b> <code>{حذف تمامی مدیران فرعی تنظیم شده برای گروه}</code>
*<b>[/#!]delete welcome</b> <code>{حذف پیغام خوش آمدگویی تنظیم شده برای گروه}</code>
*<b>[/#!]delete bots</b> <code>{حذف تمامی ربات های موجود در ابرگروه}</code>
*<b>[/#!]delete silentlist</b> <code>{حذف لیست سکوت کاربران}</code>
*<b>[/#!]delete filterlist</b> <code>{حذف لیست کلمات فیلتر شده در گروه}</code>
<b>-------------------------------</b>
<code>>راهنمای بخش خوش آمدگویی</code>
*<b>[/#!]welcome enable</b> --<code>(فعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]welcome disable</b> --<code>(غیرفعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]setwelcome text</b> --<code>(تنظیم پیغام خوش آمدگویی جدید در گروه)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلترگروه</code>
*<b>[/#!]mutechat</b> --<code>فعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]unmutechat</b> --<code>غیرفعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]mutechat number(h|m|s)</b> --<code>فیلتر تمامی گفتگو ها بر حسب زمان[ساعت|دقیقه|ثانیه]</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات حالت سکوت کاربران</code>
*<b>[/#!]silentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]unsilentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]silentlist</b> <code>--دریافت لیست کاربران حالت سکوت</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلتر-کلمات</code>
*<b>[/#!]filter word</b> <code>--افزودن عبارت جدید به لیست کلمات فیلتر شده</code>
*<b>[/#!]unfilter word</b> <code>--حذف عبارت جدید از لیست کلمات فیلتر شده</code>
*<b>[/#!]filterlist</b> <code>--دریافت لیست کلمات فیلتر شده</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات تنظیمات ابر-گروه[فیلترها]</code>
*<b>[/#!]lock|unlock link</b> --<code>(فعال سازی/غیرفعال سازی ارسال تبلیغات)</code>
*<b>[/#!]lock|unlock username</b> --<code>(فعال سازی/غیرفعال سازی ارسال یوزرنیم)</code>
*<b>[/#!]lock|unlock sticker</b> --<code>(فعال سازی/غیرفعال سازی ارسال برچسب)</code>
*<b>[/#!]lock|unlock contact</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  مخاطبین)</code>
*<b>[/#!]lock|unlock english</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(انگلیسی))</code>
*<b>[/#!]lock|unlock persian</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(فارسی))</code>
*<b>[/#!]lock|unlock forward</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  فوروارد)</code>
*<b>[/#!]lock|unlock photo</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  تصاویر)</code>
*<b>[/#!]lock|unlock video</b> --<code>(فعال سازی/غیرفعال سازی فیلتر ویدئو)</code>
*<b>[/#!]lock|unlock gif</b> --<code>(فعال سازی/غیرفعال سازی فیلتر تصاویر-متحرک)</code>
*<b>[/#!]lock|unlock music</b> --<code>(فعال سازی/غیرفعال سازی فیلتر آهنگ(MP3))</code>
*<b>[/#!]lock|unlock audio</b> --<code>(فعال سازی/غیرفعال سازی فیلتر صدا(Voice-Audio))</code>
*<b>[/#!]lock|unlock text</b> --<code>(فعال سازی/غیرفعال سازی فیلتر متن)</code>
*<b>[/#!]lock|unlock keyboard</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  درون-خطی(کیبرد شیشه))</code>
*<b>[/#!]lock|unlock tgservice</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  پیام ورود-خروج افراد)</code>
*<b>[/#!]lock|unlock pin</b> --<code>(مجاز/غیرمجاز کردن پین پیام توسط عضو عادی)</code>
*<b>[/#!]lock|unlock number(h|m|s)</b> --<code>(مجاز/غیرمجاز کردن ارسال پیغام مکرر)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش تنظیم پیغام مکرر</code>
*<b>[/#!]floodmax number</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر</code>
*<b>[/#!]floodtime</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر برحسب زمان</code>
]]
   elseif is_mod(msg) then
    help = [[از متن راهنمای مالکین گروه استفاده کنید.]]
    elseif not is_mod(msg) then
    help = [[متن راهنما برای کاربران عادی ثبت نشده است.]]
    end
   bot.sendMessage(msg.chat_id_, msg.id_, 1, help, 1, 'html')
  end
  end
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
     run(data.message_,data)
  elseif (data.ID == "UpdateMessageEdited") then
    data = data
    local function edited_cb(extra,result,success)
      run(result,data)
    end
     tdcli_function ({
      ID = "GetMessage",
      chat_id_ = data.chat_id_,
      message_id_ = data.message_id_
    }, edited_cb, nil)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
