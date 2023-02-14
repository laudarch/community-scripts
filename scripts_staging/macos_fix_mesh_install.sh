#!/usr/bin/env bash

# This script fixes MeshAgent issue #161: MacOS Ventura - Not starting meshagent on boot (Maybe Solved)
# https://github.com/Ylianst/MeshAgent/issues/161
#
# The following actions are taken:
# 1) Add the eXecute bit for directory traversal for the installation directory. This allows regular users
#    access to run the binary inside the directory, fixing the "meshagent" LaunchAgent integration with the
#    user.
# 2) Rename the LaunchAgent "meshagent.plist" to prevent conflicts with the LaunchDaemon "meshagent.plist".
#    This may not be needed but is done for good measure.
# 3) Rename the service Label inside the plist. Using "defaults" causes the plist to be rewritten in plist
#    format, not ascii.

mesh_install_dir="/opt/tacticalmesh/"
mesh_agent_plist_old="/Library/LaunchAgents/meshagent.plist"
mesh_agent_plist="/Library/LaunchAgents/meshagent-agent.plist"

if /usr/bin/stat -f "%Sp" "${mesh_install_dir}" | grep -v 'x$' >/dev/null
then
    echo "Fixing permissions on meshagent installation directory: ${mesh_install_dir}"
    chmod o+X "${mesh_install_dir}"
else
    echo "No action taken. Permissions on meshagent installation directory have already been fixed."
fi
echo

if [ -f "${mesh_agent_plist_old}" ]
then
    echo "Renaming agent plist: ${mesh_agent_plist_old}"
    mv "${mesh_agent_plist_old}" "${mesh_agent_plist}"
else
    echo "No action taken. meshagent.plist was already renamed: ${mesh_agent_plist}"
fi
echo

# New file has to exist before renaming the label.
if [ -f "${mesh_agent_plist}" ]
then
    label=$(defaults read "${mesh_agent_plist}" Label)
    if [ "${label}" != "meshagent-agent" ]
    then
        echo "Renaming meshagent label in plist: ${mesh_agent_plist}"
        echo "Warning: This will convert the plist from a text file to a binary plist file."
        echo "Here's the original in text format:"
        echo "---------- START ${mesh_agent_plist} ----------"
        cat "${mesh_agent_plist}"
        echo "---------- END ${mesh_agent_plist} ----------"
        defaults write "${mesh_agent_plist}" Label "meshagent-agent"
    else
        echo "No action taken. meshagent label was already renamed: ${label}"
    fi
fi

