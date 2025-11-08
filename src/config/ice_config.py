import os
from typing import Any, Dict, List

from aiortc import RTCIceServer


class ICEConfig:
    """ICE服务器配置管理类"""

    def __init__(self):
        # 默认STUN服务器
        self.default_stun_urls = [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun.stunprotocol.org:3478",
        ]

        # TURN服务器配置（使用环境变量或默认公共服务器）
        self.turn_servers = [
            # OpenRelay TURN 服务器 - UDP on port 80
            {
                "urls": "turn:openrelay.metered.ca:80",
                "username": "openrelayproject",
                "credential": "openrelayproject",
            },
            # OpenRelay TURN 服务器 - TCP on port 80
            {
                "urls": "turn:openrelay.metered.ca:80?transport=tcp",
                "username": "openrelayproject",
                "credential": "openrelayproject",
            },
            # OpenRelay TURN 服务器 - UDP on port 443
            {
                "urls": "turn:openrelay.metered.ca:443",
                "username": "openrelayproject",
                "credential": "openrelayproject",
            },
            # OpenRelay TURN 服务器 - TCP on port 443
            {
                "urls": "turn:openrelay.metered.ca:443?transport=tcp",
                "username": "openrelayproject",
                "credential": "openrelayproject",
            },
            # OpenRelay TURNS 服务器 - TLS on port 443 (最可靠)
            {
                "urls": "turns:openrelay.metered.ca:443",
                "username": "openrelayproject",
                "credential": "openrelayproject",
            },
            # OpenRelay TURNS 服务器 - TLS TCP on port 443
            {
                "urls": "turns:openrelay.metered.ca:443?transport=tcp",
                "username": "openrelayproject",
                "credential": "openrelayproject",
            },
            # 备用 STUN/TURN 服务器
            {
                "urls": "stun:relay.metered.ca:80",
            },
        ]

    def get_ice_config(self) -> Dict[str, Any]:
        """获取前端ICE配置"""
        ice_servers = []

        # 添加TURN服务器（优先）
        for turn_server in self.turn_servers:
            ice_servers.append(turn_server)

        # 添加默认STUN服务器
        for url in self.default_stun_urls:
            ice_servers.append({"urls": url})

        # 使用 all 策略，允许直连和中继
        return {
            "iceServers": ice_servers,
            "iceCandidatePoolSize": 10,
            "iceTransportPolicy": "all",  # 允许直连和 TURN 中继
            "bundlePolicy": "max-bundle",
            "rtcpMuxPolicy": "require",
        }

    def get_server_ice_servers(self) -> List[RTCIceServer]:
        """获取服务器端ICE服务器对象"""
        servers = []

        # 添加默认STUN服务器
        for url in self.default_stun_urls:
            servers.append(RTCIceServer(urls=url))

        # 添加TURN服务器
        for turn_server in self.turn_servers:
            servers.append(
                RTCIceServer(
                    urls=turn_server["urls"],
                    username=turn_server.get("username"),
                    credential=turn_server.get("credential"),
                )
            )

        return servers


# 全局实例
ice_config = ICEConfig()
