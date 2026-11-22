(() => {
    const app = document.getElementById('app');
    const isFiveM = typeof GetParentResourceName === 'function';

    const elements = {
        brandTitle: document.getElementById('brand-title'),
        serverLabel: document.getElementById('server-label'),
        playerName: document.getElementById('player-name'),
        playerInitial: document.getElementById('player-initial'),
        playerId: document.getElementById('player-id'),
        playerWeapon: document.getElementById('player-weapon'),
        friendSearch: document.getElementById('friend-search'),
        friendSectionTitle: document.getElementById('friend-section-title'),
        friendEmpty: document.getElementById('friend-empty'),
        friendEmptyTitle: document.getElementById('friend-empty-title'),
        friendEmptyCopy: document.getElementById('friend-empty-copy'),
        lfgSection: document.querySelector('.lfg-section'),
        lfgContent: document.getElementById('lfg-content'),
        lfgTitle: document.getElementById('lfg-title'),
        lfgCopy: document.getElementById('lfg-copy'),
        lfgStatusButton: document.getElementById('lfg-status-button'),
        toast: document.getElementById('toast'),
        chatForm: document.getElementById('chat-form'),
        chatInput: document.getElementById('chat-input')
    };

    let activeFriendTab = 'Friends';
    let lookingForGroup = false;
    let toastTimer = null;

    function postNui(endpoint, payload = {}) {
        if (!isFiveM) return Promise.resolve();

        return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(payload)
        }).catch(() => {});
    }

    function showToast(message) {
        elements.toast.textContent = message;
        elements.toast.classList.add('is-visible');
        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(() => elements.toast.classList.remove('is-visible'), 2600);
    }

    function openMenu(data = {}) {
        const name = String(data.playerName || 'NOVA').trim() || 'PLAYER';
        const serverId = data.serverId == null ? '01' : String(data.serverId).padStart(2, '0');
        const weapon = String(data.weaponLabel || 'CARBINE RIFLE')
            .replace(/^WEAPON_/i, '')
            .replaceAll('_', ' ');

        elements.playerName.textContent = name.toUpperCase();
        elements.playerInitial.textContent = Array.from(name)[0].toUpperCase();
        elements.playerId.textContent = serverId;
        elements.playerWeapon.textContent = weapon.toUpperCase();
        if (data.serverLabel) elements.serverLabel.textContent = String(data.serverLabel).toUpperCase();
        if (data.menuTitle) elements.brandTitle.innerHTML = `${escapeHtml(String(data.menuTitle).split(' ')[0])}<span>//</span>${escapeHtml(String(data.menuTitle).split(' ').slice(1).join(' ') || 'OPS')}`;

        app.classList.add('is-open');
        app.setAttribute('aria-hidden', 'false');
    }

    function closeMenu(notifyClient = true) {
        app.classList.remove('is-open');
        app.setAttribute('aria-hidden', 'true');
        if (notifyClient) postNui('close');
    }

    function escapeHtml(value) {
        return value.replace(/[&<>"']/g, character => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        })[character]);
    }

    function updateFriendEmptyState() {
        const query = elements.friendSearch.value.trim();
        elements.friendEmpty.classList.toggle('is-add-mode', activeFriendTab === 'Add');

        if (query) {
            elements.friendSectionTitle.textContent = 'SEARCH RESULTS';
            elements.friendEmptyTitle.textContent = 'NO MATCHES FOUND';
            elements.friendEmptyCopy.textContent = `No players match “${query}”. Try a server ID or a different name.`;
            return;
        }

        elements.friendSectionTitle.textContent = activeFriendTab.toUpperCase();
        if (activeFriendTab === 'Recents') {
            elements.friendEmptyTitle.textContent = 'NO RECENT PLAYERS';
            elements.friendEmptyCopy.textContent = 'Players you recently met will appear here.';
        } else if (activeFriendTab === 'Add') {
            elements.friendEmptyTitle.textContent = 'FIND YOUR CREW';
            elements.friendEmptyCopy.textContent = 'Search by player name or server ID to send a friend request.';
        } else {
            elements.friendEmptyTitle.textContent = 'NO FRIENDS YET';
            elements.friendEmptyCopy.textContent = 'Add friends from recently played or send a request in Add Friend.';
        }
    }

    document.querySelectorAll('.nav-item').forEach(button => {
        button.addEventListener('click', () => {
            document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('is-active'));
            button.classList.add('is-active');
            showToast(`${button.dataset.page} selected — connect this tab to your server mode.`);
        });
    });

    document.querySelectorAll('[data-friend-tab]').forEach(button => {
        button.addEventListener('click', () => {
            activeFriendTab = button.dataset.friendTab;
            document.querySelectorAll('[data-friend-tab]').forEach(tab => tab.classList.toggle('is-active', tab === button));
            updateFriendEmptyState();
            if (activeFriendTab === 'Add') window.setTimeout(() => elements.friendSearch.focus(), 0);
        });
    });

    elements.friendSearch.addEventListener('input', updateFriendEmptyState);

    document.getElementById('add-friend-button').addEventListener('click', () => {
        document.querySelector('[data-friend-tab="Add"]').click();
        elements.friendSearch.focus();
    });

    document.querySelectorAll('.team-slot').forEach(button => {
        button.addEventListener('click', () => {
            showToast(`Squad slot ${button.dataset.slot} is ready — connect invites to your party system.`);
        });
    });

    document.getElementById('collapse-panel').addEventListener('click', () => {
        app.classList.add('panel-collapsed');
    });

    document.getElementById('reopen-panel').addEventListener('click', () => {
        app.classList.remove('panel-collapsed');
    });

    document.getElementById('close-menu').addEventListener('click', () => closeMenu(true));

    document.getElementById('lfg-toggle').addEventListener('click', event => {
        const expanded = elements.lfgSection.classList.toggle('is-collapsed') === false;
        event.currentTarget.setAttribute('aria-expanded', String(expanded));
    });

    elements.lfgStatusButton.addEventListener('click', () => {
        lookingForGroup = !lookingForGroup;
        elements.lfgStatusButton.classList.toggle('is-looking', lookingForGroup);
        elements.lfgStatusButton.querySelector('span').textContent = lookingForGroup ? 'STATUS: LOOKING FOR GROUP' : 'SET STATUS: LOOKING';
        elements.lfgTitle.textContent = lookingForGroup ? 'YOU ARE LOOKING FOR A GROUP' : 'NOBODY IS LOOKING FOR A GROUP';
        elements.lfgCopy.textContent = lookingForGroup
            ? 'Your status is set locally. Connect it to your server to find a squad.'
            : 'Set your status to Looking for Group to appear here for others.';
        showToast(lookingForGroup ? 'Looking for Group status enabled.' : 'Looking for Group status disabled.');
    });

    elements.chatForm.addEventListener('submit', event => {
        event.preventDefault();
        const message = elements.chatInput.value.trim();
        if (!message) return;
        showToast('Connect this chat box to your server chat resource to send messages.');
        elements.chatInput.value = '';
    });

    document.addEventListener('keydown', event => {
        if (event.key === 'Escape' && app.classList.contains('is-open')) {
            event.preventDefault();
            closeMenu(true);
        }
    });

    window.addEventListener('message', event => {
        const data = event.data || {};
        if (data.action === 'open') openMenu(data);
        if (data.action === 'close') closeMenu(false);
    });

    if (!isFiveM) {
        document.body.classList.add('browser-preview');
        openMenu({
            playerName: 'NOVA',
            serverId: 27,
            menuTitle: 'NEON DISTRICT',
            serverLabel: 'LOS SANTOS / US-01',
            weaponLabel: 'CARBINE RIFLE'
        });
    }
})();
