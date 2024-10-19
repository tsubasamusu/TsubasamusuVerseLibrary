# 内容
## プロップを常にプレイヤーの方向に向ける（look_player_prop_manager）
- ``UpdateSpan``：更新頻度
    - 単位は秒
    - 0.0 秒に設定すると正常に動作しなくなる
- ``StartFollowingTrigger``：追従を開始するための ``trigger_device``
    - このトリガーを実行したプレイヤーに追従するようになる
- ``StopFollowingTrigger``：追従を停止するための ``trigger_device``
    - 追従を停止してから再開するまで ``UpdateSpan`` 以上の時間を空けると安全
- ``TargetPropDataArray``：対象のプロップのデータの配列
    - ``TargetProp``：対象の ``creative_prop``
    - ``RotateYaw``：ヨー軸を回転させるかどうか
    - ``RotatePitch``：ピッチ軸を回転させるかどうか