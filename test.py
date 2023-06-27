import hashlib,json,requests,re
from requests.structures import CaseInsensitiveDict
import os
import threading

def main():
    link = input("Enter game link: ")
    score = input("Enter score: ")
    time = input("Enter time: ")
    
    if link=='' or score == '' or time == '':
        result = "Fill empty field!"
        print(result)
    else:
        if not check_is_digit(score) or not check_is_digit(time):
            result = "Score and time fields should be number!"
            print(result)
        else:
            game_url = game_link(link)
            if game_url ==False:
                result = "Something went wrong! Not valid link."
                print(result)
            else:
                token = get_token(game_url)
                checksum = get_checksum(score, time, game_url)
                Game_number = game_id(game_url)
                result = send_score(score, time, checksum, token, game_url, Game_number)
                if result == False:
                    result = "Something went wrong! Check your internet."
                    print(result)
                else:
                    print(result)


def get_checksum(score,playTime,url):
	gameStateData = ""
	str2hash = f"{score}:{playTime}:{url}:{gameStateData}:crmjbjm3lczhlgnek9uaxz2l9svlfjw14npauhen"
	result = hashlib.md5(str2hash.encode())
	checksum = result.hexdigest()
	return checksum

def get_token(Gameurl):
	url = "http://api.service.gameeapp.com"
	headers = CaseInsensitiveDict()
	headers["Host"] = "api.service.gameeapp.com"
	headers["Connection"] = "keep-alive"
	headers["Content-Length"] = "224"
	headers["client-language"] = "en"
	headers["x-install-uuid"] = "0c1cd354-302a-4e76-9745-6d2d3dcf2c56"
	headers["sec-ch-ua-mobile"] = "?0"
	headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36"
	headers["sec-ch-ua-platform"] = "Windows"
	headers["Content-Type"] = "application/json"
	headers["Accept"] = "*/*"
	headers["Origin"] = "https://prizes.gamee.com"
	headers["Sec-Fetch-Site"] = "cross-site"
	headers["Sec-Fetch-Mode"] = "cors"
	headers["Sec-Fetch-Dest"] = "empty"
	headers["Referer"] = "https://prizes.gamee.com/"
	headers["Accept-Encoding"] = "gzip, deflate, br"
	headers["Accept-Language"] = "en-US,en;q=0.9"
	data = '{"jsonrpc":"2.0","id":"user.authentication.botLogin","method":"user.authentication.botLogin","params":{"botName":"telegram","botGameUrl":"'+Gameurl+'","botUserIdentifier":null}}'
	try :
		resp = requests.post(url, headers=headers, data=data)
	except:
		return False

	print(resp.status_code)
	if resp.status_code == 200:
		result_data = resp.json()
		token = result_data['result']['tokens']['authenticate']
		return token
	else:
		return False

def game_id(game_url):

	url = "https://api.service.gameeapp.com/"

	headers = CaseInsensitiveDict()
	headers["accept"] = "*/*"
	headers["accept-encoding"] = "gzip, deflate, br"
	headers["accept-language"] = "en-US,en;q=0.9"
	headers["cache-control"] = "no-cache"
	headers["client-language"] = "en"
	headers["content-length"] = "173"
	headers["Content-Type"] = "application/json"
	headers["origin"] = "https://prizes.gamee.com"
	headers["pragma"] = "no-cache"
	headers["referer"] = "https://prizes.gamee.com/"
	headers["sec-ch-ua-mobile"] = "?0"
	headers["sec-ch-ua-platform"] = "Windows"
	headers["sec-fetch-dest"] = "empty"
	headers["sec-fetch-mode"] = "cors"
	headers["sec-fetch-site"] = "cross-site"
	headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36"
	data = '{"jsonrpc":"2.0","id":"game.getWebGameplayDetails","method":"game.getWebGameplayDetails","params":{"gameUrl":"'+game_url+'"}}'

	try :
		resp = requests.post(url, headers=headers, data=data)
	except:
		return False
	if resp.status_code == 200:
		result_data = resp.json()
		return result_data['result']['game']['id']
	else:
		return False
	

def send_score(score,timePlay,checksum,token,game_url,game_id):
	url = "http://api.service.gameeapp.com"

	headers = CaseInsensitiveDict()
	headers["Host"] = "api.service.gameeapp.com"
	headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/89.0.4389.90 Safari/537.36"
	headers["Accept"] = "*/*"
	headers["Accept-Language"] = "en-US,en;q=0.5"
	headers["Accept-Encoding"] = "gzip, deflate"
	headers["X-Install-Uuid"] = "91516df9-f651-40ef-9c11-ccd357429228"
	headers["Client-Language"] = "en"
	headers["Content-Type"] = "application/json"
	headers["Origin"] = "https://prizes.gamee.com"
	headers["Referer"] = "https://prizes.gamee.com/"
	headers["Sec-Fetch-Dest"] = "empty"
	headers["Sec-Fetch-Mode"] = "cors"
	headers["Sec-Fetch-Site"] = "cross-site"
	headers["Te"] = "trailers"
	headers["Authorization"] = "Bearer {my_token}".format(my_token=token)
	data = '{"jsonrpc":"2.0","id":"game.saveWebGameplay","method":"game.saveWebGameplay","params":{"gameplayData":{"gameId":'+str(game_id)+',"score":'+str(score)+',"playTime":'+str(timePlay)+',"gameUrl":"'+game_url+'","metadata":{"gameplayId":30},"releaseNumber":8,"gameStateData":null,"createdTime":"2021-12-28T03:20:24+03:30","checksum":"'+checksum+'","replayVariant":null,"replayData":null,"replayDataChecksum":null,"isSaveState":false,"gameplayOrigin":"game"}}}'

	try:
		resp = requests.post(url, headers=headers, data=data)
	except:
		return False

	
	if resp.status_code == 200:
		result_text = ""
		status = 0
		my_json = resp.json()
		keys_list = list(my_json)
		for i in keys_list:
			if i == "error":
				result_text = my_json['error']['message']+"\n"+my_json['error']['data']['reason']+"\n"+"try after "+my_json['user']['cheater']['banStatus']
				status = 1
				break

		if status == 0:
			user_posin_rank = my_json['result']['surroundingRankings'][0]['ranking']
			for user in user_posin_rank:
				result_text = str(user['rank'])+" - "+ user['user']['firstname']+" "+user['user']['lastname']+" score : "+str(user['score'])+"\n"+result_text
		return result_text
	else:
		return False


def game_link(url):
	pattern = r"https:\/\/prizes\.gamee\.com(\/game-bot\/.*)#tg"
	result = re.match(pattern, url)
	if result:
		link = result.groups(0)[0]
		return link
	else:
		return False

def check_is_digit(num):
    if num.strip().isdigit():
        return True
    else:
        return False


if __name__ == '__main__':
    main()