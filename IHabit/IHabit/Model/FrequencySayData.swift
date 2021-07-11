//
//  FrequencySayData.swift
//  IHabit
//
//  Created by 沈志陽 on 2021/6/10.
//

import Foundation

struct FrequencySentence {
    let sentences: [String] = [
        "不經巨大的困難，不會有偉大的事業" ,
        "苦難磨鍊一些人，也毀滅另一些人" ,
        "改變你的想法，你就改變了自己的世界" ,
        "不要等待時機永遠不會恰到好處" ,
        "生命如同寓言其價值不在與長短而在與內容" ,
        "你相信什麼你就成為什麼樣的人" ,
        "生命不可能有兩次但許多人連一次也不善於度過" ,
        "人的一生是短的但如果卑劣地過這一生就太長了" ,
        "我的努力求學沒有得到別的好處只不過是愈來愈發覺自己的無知" ,
        "生活的道路一旦選定就要勇敢地走到底決不回頭" ,
        "生命是一條艱險的峽谷只有勇敢的人才能通過" ,
        "要么你主宰生活要么你被生活主宰" ,
        "不幸可能成為通向幸福的橋樑" ,
        "人生就是學校與其說好的教師是幸福不如說好的教師是不幸" ,
        "接受挑戰就可以享受勝利的喜悅" ,
        "節制使快樂增加並使享受加強" ,
        "今天應做的事沒有做明天再早也是耽誤了" ,
        "決定一個人的一生以及整個命運的只是一瞬之間" ,
        "一個不注意小事情的人永遠不會成就大事業" ,
        "浪費時間是一樁大罪過" ,
        "既然我已經踏上這條道路那麼任何東西都不應妨礙我沿著這條路走下去" ,
        "教育需要花費錢而無知也是一樣" ,
        "堅持意志偉大的事業需要始終不渝的精神" ,
        "你活了多少歲不算什麼重要的是你是如何度過這些歲月的" ,
        "內外相應言行相稱" ,
        "你熱愛生命嗎？那麼別浪費時間因為時間是組成生命的材料" ,
        "堅強的信心能使平凡的人做出驚人的事業" ,
        "讀一切好書就是和許多高尚的人談話" ,
        "真正的人生只有在經過艱難卓絕的鬥爭之後才能實現" ,
        "偉大的事業需要決心能力" ,
        "沒有人事先了解自己到底有多大的力量直到他試過以後才知道" ,
        "敢於浪費哪怕一個鐘頭時間的人說明他還不懂得珍惜生命的全部價值" ,
        "感激每一個新的挑戰因為它會鍛造你的意志和品格" ,
        "共同的事業共同的鬥爭可以使人們產生忍受一切的力量" ,
        "古之立大事者不惟有超世之才亦必有堅忍不拔之志" ,
        "故立志者為學之心也；為學者立誌之事也" ,
        "讀一本好書就如同和一個高尚的人在交談" ,
        "學習是勞動是充滿思想的勞動" ,
        "好的書籍是最貴重的珍寶" ,
        "讀書是易事思索是難事但兩者缺一" ,
        "讀書是在別人思想的幫助下建立起自己的思想" ,
        "合理安排時間就等於節約時間" ,
        "你想成為幸福的人嗎？但願你首先學會吃得起苦" ,
        "拋棄時間的人時間也拋棄他" ,
        "普通人只想到如何度過時間有才能的人設法利用時間" ,
        "一次失敗只是證明我們成功的決心還夠堅強" ,
        "取得成就時堅持不懈要比遭到失敗時頑強不屈更重要" ,
        "人的一生是短的但如果卑劣地過這一生就太長了" ,
        "失敗是堅忍的最後考驗" ,
        "不要迴避苦惱和困難挺起身來向它挑戰進而克服它" ,
        "那腦袋裡的智慧就像打火石裡的火花一樣不去打它是不肯出來的" ,
        "最困難的事情就是認識自己" ,
        "有勇氣承擔命運這才是英雄好漢" ,
        "最靈繁的人也看不見自己的背脊" ,
        "閱讀使人充實會談使人敏捷寫作使人精確" ,
        "最大的驕傲於最大的自卑都表示心靈的最軟弱無力" ,
        "自知之明是最難得的知識" ,
        "勇氣通往天堂怯懦通往地獄" ,
        "有時候讀書是一種巧妙地避開思考的方法" ,
        "閱讀一切好書如同和過去最傑出的人談話" ,
        "越是沒有本領的就越加自命不凡" ,
        "越是無能的人越喜歡挑剔別人的錯兒" ,
        "知人者智自知者明自勝者強" ,
        "意志堅強的人能把世界放在手中像泥塊一樣任意揉捏" ,
        "最具挑戰性的挑戰莫過於提升自我" ,
        "失敗也是我需要的它和成功對我一樣有價值" ,
        "一個人即使已登上頂峰也仍要自強不息" ,
        "最大的挑戰和突破在於用人而用人最大的突破在於信任人" ,
        "自己活著就是為了使別人過得更美好" ,
        "要掌握書莫被書掌握；要為生而讀莫為讀而生" ,
        "要知道對好事的稱頌過於誇大也會招來人們的反感輕蔑和嫉妒" ,
        "誰和我一樣用功誰就會和我一樣成功" ,
        "一切節省歸根到底都歸結為時間的節省" ,
        "意志命運往往背道而馳決心到最後會全部推倒" ,
        "過去一切時代的精華盡在書中" ,
        "深窺自己的心而後發覺一切的奇蹟在你自己" ,
        "只有把抱怨環境的心情化為上進的力量才是成功的保證" ,
        "知之者不如好之者好之者不如樂之者" ,
        "大膽和堅定的決心能夠抵得上武器的精良" ,
        "意志是一個強壯的盲人倚靠在明眼的跛子肩上" ,
        "只有永遠躺在泥坑里的人才不會再掉進坑里" ,
        "希望的燈一旦熄滅生活剎那間變成了一片黑暗" ,
        "要成功不需要什麼特別的才能只要把你能做的小事做得好就行了" ,
        "形成天才的決定因素應該是勤奮" ,
        "學到很多東西的訣竅就是一下子不要學很多" ,
        "自己的鞋子自己知道緊在哪裡" ,
        "我們唯一不會改正的缺點是軟弱" ,
        "我這個人走得很慢但是我從不後退" ,
        "勿問成功的秘訣為何且盡全力做你應該做的事吧" ,
        "對於不屈不撓的人來說沒有失敗這回事" ,
        "學問是異常珍貴的東西從任何源泉吸收都不可恥" ,
        "堅強的信念能贏得強者的心並使他們變得更堅強" ,
        "一個人幾乎可以在任何他懷有無限熱忱的事情上成功" ,
        "卓越的人一大優點是：在不利與艱難的遭遇裡百折不饒" ,
        "本來無望的事大膽嘗試往往能成功" ,
        "我們若已接受最壞的就再沒有什麼損失" ,
        "只有在人群中間才能認識自己" ,
        "書籍把我們引入最美好的社會使我們認識各個時代的偉大智者" ,
        "當一個人用工作去迎接光明光明很快就會來照耀著他" ,
        "如果你能做夢你就能實現它" ]

    func getSentence(index: Int) -> String {
        guard index >= 0, index <= sentences.count - 1 else {
            return ""
        }
        return sentences[index]
    }
    func getSentenceCount() -> Int {
        return sentences.count
    }
}
