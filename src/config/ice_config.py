import os
from typing import Any, Dict, List, Optional

from aiortc import RTCIceServer


class ICEConfig:
    """ICE服务器配置管理类"""

    def __init__(self):
        self._enable_default_turn = self._env_true("ENABLE_DEFAULT_TURN_SERVERS", True)

        # 默认STUN服务器
        self.default_stun_urls = [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun.stunprotocol.org:3478",
        ]

        # TURN服务器配置（优先使用环境变量,否则使用公共服务器）
        custom_turn = os.getenv("TURN_SERVER_URL")
        custom_turn_user = os.getenv("TURN_USERNAME")
        custom_turn_cred = os.getenv("TURN_CREDENTIAL")

        if custom_turn and custom_turn_user and custom_turn_cred:
            # 使用自定义TURN服务器
            self.turn_servers = [
                {
                    "urls": custom_turn,
                    "username": custom_turn_user,
                    "credential": custom_turn_cred,
                }
            ]
        else:
            if self._enable_default_turn:
                # 使用公共TURN服务器（多个备选）
                self.turn_servers = [
                    # Metered 免费 TURN 服务器 - 高优先级，较稳定
                    {
                        "urls": "turn:a.relay.metered.ca:80",
                        "username": "87ea5960eaa8f29d34f12a24",
                        "credential": "BWAj3Fe/LpNeOKNE",
                    },
                    {
                        "urls": "turn:a.relay.metered.ca:443",
                        "username": "87ea5960eaa8f29d34f12a24",
                        "credential": "BWAj3Fe/LpNeOKNE",
                    },
                    {
                        "urls": "turns:a.relay.metered.ca:443",
                        "username": "87ea5960eaa8f29d34f12a24",
                        "credential": "BWAj3Fe/LpNeOKNE",
                    },
                    # OpenRelay TURN 服务器 - 备用
                    {
                        "urls": "turn:openrelay.metered.ca:80",
                        "username": "openrelayproject",
                        "credential": "openrelayproject",
                    },
                    {
                        "urls": "turn:openrelay.metered.ca:443",
                        "username": "openrelayproject",
                        "credential": "openrelayproject",
                    },
                    {
                        "urls": "turns:openrelay.metered.ca:443",
                        "username": "openrelayproject",
                        "credential": "openrelayproject",
                    },
                ]
            else:
                self.turn_servers = []

    def _env_true(self, name: str, default: bool) -> bool:
        """解析类似于 ENABLE_xxx=1/true 的布尔环境变量"""
        value = os.getenv(name)
        if value is None:
            return default
        return value.strip().lower() not in {"0", "false", "off", "no"}


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
