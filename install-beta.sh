from Plugins.Plugin import PluginDescriptor
from .provider_selection import XPortalProviderSelection
from .web_server import start_web_server
from .config import init_config
import os
import json

try:
    from enigma import addFont
    fonts_dir = os.path.join(os.path.dirname(__file__), "fonts")
    if os.path.exists(fonts_dir):
        font_path = os.path.join(fonts_dir, "NotoSans-Bold.ttf")
        if not os.path.exists(font_path):
            ttf_files = [f for f in os.listdir(fonts_dir) if f.lower().endswith('.ttf')]
            if ttf_files:
                font_path = os.path.join(fonts_dir, ttf_files[0])
        if os.path.exists(font_path):
            addFont(font_path, "XPortalFont", 100, 0)
            print("[XPortal] Registered custom font %s successfully" % os.path.basename(font_path))
except Exception as e:
    print("[XPortal] Font registration error:", e)

def _check_update_bg(callback):
    online_version = ""
    try:
        import urllib.request
        import ssl
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        req = urllib.request.Request("https://raw.githubusercontent.com/azroukarim/XPortal/refs/heads/main/update.md", headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=3, context=ctx) as response:
            online_version = response.read().decode('utf-8').strip()
    except:
        pass
        
    if not online_version:
        try:
            import urllib2
            import ssl
            ctx = ssl._create_unverified_context()
            req = urllib2.Request("https://raw.githubusercontent.com/azroukarim/XPortal/refs/heads/main/update.md", headers={'User-Agent': 'Mozilla/5.0'})
            response = urllib2.urlopen(req, timeout=3, context=ctx)
            online_version = response.read().decode('utf-8').strip()
        except:
            pass
            
    if not online_version:
        os.system('curl -kLs "https://raw.githubusercontent.com/azroukarim/XPortal/refs/heads/main/update.md" > /tmp/xportal_ver 2>/dev/null || wget -qO- "https://raw.githubusercontent.com/azroukarim/XPortal/refs/heads/main/update.md" > /tmp/xportal_ver 2>/dev/null')
        if os.path.exists('/tmp/xportal_ver'):
            try:
                with open('/tmp/xportal_ver', 'r') as f:
                    online_version = f.read().strip()
            except:
                pass

    from twisted.internet import reactor
    reactor.callFromThread(callback, online_version)

def main(session, **kwargs):
    init_config()
    start_web_server()
    
    def on_checked(online_version):
        if online_version and online_version.startswith("v"):
            online_version = online_version[1:]
        
        has_update = False
        if online_version:
            curr_dir = os.path.dirname(os.path.abspath(__file__))
            v_file = os.path.join(curr_dir, "version.json")
            local_version = "1.0"
            if os.path.exists(v_file):
                try:
                    with open(v_file, "r", encoding="utf-8") as f:
                        v_data = json.load(f)
                        local_version = v_data.get("version", "v1.0")
                        if local_version.startswith("v"):
                            local_version = local_version[1:]
                except:
                    pass
            
            def v_tuple(v_str):
                try:
                    return tuple(map(int, (v_str.split("."))))
                except:
                    return (0,)
                    
            if v_tuple(online_version) > v_tuple(local_version):
                has_update = True
        
        if has_update:
            print("[XPortal] Nouvelle version disponible. Désinstallation automatique du plugin...")
            import time
            ts = int(time.time())
            plugin_dir = os.path.dirname(os.path.abspath(__file__))
            # Construction du script de désinstallation
            script_content = f'''#!/bin/sh
echo "XPortal: Désinstallation du plugin..."
# Suppression du répertoire du plugin
rm -rf "{plugin_dir}"
# Suppression des fichiers de configuration
rm -rf /etc/enigma2/XPortal
rm -f /etc/enigma2/xportal_bookmarks.json
# Nettoyage des fichiers temporaires
rm -f /tmp/xportal_update.sh
rm -f /tmp/xinst.sh
echo "Plugin XPortal et ses configurations supprimés."
'''
            script_path = "/tmp/xportal_uninstall.sh"
            try:
                with open(script_path, "w") as f:
                    f.write(script_content)
                os.chmod(script_path, 0o755)
                import subprocess
                subprocess.Popen(["/bin/sh", script_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                # Fermer le plugin immédiatement
                session.close()
            except Exception as e:
                print("[XPortal] Erreur lors du lancement du script de désinstallation:", e)
                # En cas d'échec, ouvrir l'interface normalement
                session.open(XPortalProviderSelection)
            return
        
        # Pas de mise à jour, ouvrir l'interface normale
        session.open(XPortalProviderSelection)

    from twisted.internet import reactor
    reactor.callInThread(_check_update_bg, on_checked)

def menuHook(menuid, **kwargs):
    if menuid == "mainmenu":
        from .config import load_global_config
        config = load_global_config()
        if config.get("show_in_main_menu", False):
            return [("XPortal", main, "xportal_main_menu", 50)]
    return []

def Plugins(**kwargs):
    return [
        PluginDescriptor(
            name="XPortal",
            description="Play IPTV, M3U, Xtream & Stalker",
            where=PluginDescriptor.WHERE_PLUGINMENU,
            icon="skin/plugin.png",
            fnc=main
        ),
        PluginDescriptor(
            name="XPortal",
            description="Play IPTV, M3U, Xtream & Stalker",
            where=PluginDescriptor.WHERE_EXTENSIONSMENU,
            fnc=main
        ),
        PluginDescriptor(
            name="XPortal",
            description="Play IPTV, M3U, Xtream & Stalker",
            where=PluginDescriptor.WHERE_MENU,
            fnc=menuHook
        )
    ]
