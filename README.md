# **聊天**GO

一款真正的聊天軟體

## 預計會做

- [ ] ChatSetting 下方用GridView或其他顯示所有member (Star 1)
- [ ] ChatSetting 修改圖片或聊天室名稱，要能修改firestore 及 所有 member 在firestore存的chatRoom (Star 4)
- [ ] mainPage 那的 friendPage 修改成可分組功能 如有需要可把添加好友拉到drawer 裡面 (Star 3)
- [ ] 已讀功能 (Star 5)
- [ ] 將主題設定 設定成 可預覽app畫面 (Star 3)
- [ ] 用ListTile 來製作被添加好友page 需順便修改 addFriend 設定fireStore 來存 (Star 3)
- [ ] 將好友功能從每個user預設改為直接讀取 doc 資訊

## 已知問題

- member page

  1. 聊天室修改成單獨聊天室
   - 只能存放 chatRoom doc id 進 user fireStore 的chatRoom
     - 聊天室新增 imageURL 功能
  2. 無法刪除聊天室
- friend page

  1. 封鎖 刪除功能還沒製作
  2. 先添加好友更改頭像沒有更新
  3. 新增好友後 另一邊不會有被加入的通知 也不會直接出現 (這大概可以往express那邊弄)
- chat page

  1. 可傳輸文字及圖片/影片及gif暫且不能
  2. 還沒做出已讀功能
  3. 還沒測試別人的訊息的部分
  4. -更改頭貼後傳訊息並未更改頭貼-
- setting page
  
  2. 並不能記憶上次使用的主題是哪個主題/可能需記錄到firestore user裡面

## 未來隱憂

- 如果chatRoom的message 變多了可能會有doc.get 會容量超大的問題，如要上市fireStore 需改成 chatRoom message分開