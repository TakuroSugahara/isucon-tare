package main

import (
	"bytes"
	"encoding/binary"
	"fmt"

	"github.com/bradfitz/gomemcache/memcache"
)

// 構造体を定義してmemcacheを取り扱う

var (
	memcacheClient *memcache.Client
)

type CommentCount struct {
	Value int
}

func Init() {
}

func Get() {
	var postID int = 1

	// memcacheから取得
	cachedCommentsCountKey := fmt.Sprintf("comments.%d.count", postID)
	cacheItem, err := memcacheClient.Get(cachedCommentsCountKey)
	// MEMO: cacheがない場合にもエラーになるのでignoreしてもいいようにハンドリング
	if err != nil && err.Error() != "memcache: cache miss" {
		fmt.Println("GetKey", err)
		return 
	}

	if cacheItem == nil {
		// FIXME: キャッシュitemハンドリング
	}

	s := CommentCount{}
	reader := bytes.NewReader(cacheItem.Value)
	binary.Read(reader, binary.LittleEndian, &s)

	fmt.Println("キャッシュバリュー", a.Value)
}

func Set() {
	// memcacheに構造体でcommentCountを追加
	s := CommentCount{Value: commentCount}
	// バッファを作成
	buf := new(bytes.Buffer)
	binary.Write(buf, binary.LittleEndian, &s)

	// 取得語、cacheに保存
	memcacheClient.Set(&memcache.Item{Key: cachedCommentsCountKey, Value: buf.Bytes()})
}

func Delete() {
	// memcacheから削除
	memcacheClient.Delete(cachedCommentsCountKey)
	// MEMO: cacheがない場合にもエラーになるのでignoreしてもいいようにハンドリング
	if err := memcacheClient.Delete(cachedCommentsKeyAll); err != nil && err.Error() != "memcache: cache miss" {
  fmt.Println("DelteKeyAll", err)
  return
}
