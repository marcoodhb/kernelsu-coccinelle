// Coccinelle scope-minimized patches for KernelSU
// From: https://github.com/backslashxx/KernelSU/issues/5#issuecomment-2878532104


// File: fs/exec.c
// Adds hook to asmlinkage int sys_execve()

@do_execve_hook_minimized depends on file in "fs/exec.c"@
identifier filenam, __argv, __envp;
identifier argv, envp;
type T1, T2;
attribute name __read_mostly;
@@

+#ifdef CONFIG_KSU
+extern __attribute__((hot)) int ksu_handle_execveat(int *fd, struct filename **filename_ptr,
+				void *argv, void *envp, int *flags);
+#endif
do_execve(struct filename *filenam, T1 __argv, T2 __envp) {
...
 	struct user_arg_ptr argv = { .ptr.native = __argv };
 	struct user_arg_ptr envp = { .ptr.native = __envp };

+#ifdef CONFIG_KSU
+	ksu_handle_execveat((int *)AT_FDCWD, &filenam, &argv, &envp, 0);
+#endif
...
}

@compat_do_execve_hook_minimized depends on file in "fs/exec.c"@
identifier filenam, argv, envp;
@@

compat_do_execve(struct filename *filenam, ...) {
...
+#ifdef CONFIG_KSU // 32-bit su, 32-on-64 ksud support
+	ksu_handle_execveat((int *)AT_FDCWD, &filenam, &argv, &envp, 0);
+#endif
 	return do_execveat_common(AT_FDCWD, filenam, argv, envp, 0);
}


// File: fs/open.c
// Adds hook to SYSCALL_DEFINE3(faccessat, ...).

@sys_faccessat_hook_minimized depends on file in "fs/open.c"@
identifier dfd, filename, mode;
statement S1, S2;
attribute name __user;
@@

+#ifdef CONFIG_KSU
+extern __attribute__((hot)) int ksu_handle_faccessat(int *dfd, const char __user **filename_user,
+				int *mode, int *flags);
+#endif
faccessat(int dfd, const char __user *filename, int mode) {
... when != S1
+#ifdef CONFIG_KSU
+	ksu_handle_faccessat(&dfd, &filename, &mode, NULL);
+#endif
S2
...
}

// File: fs/read_write.c
// Adds hook to SYSCALL_DEFINE3(read, ...).

@sys_read_hook_minimized depends on file in "fs/read_write.c" exists@
identifier fd, buf, count, ret, pos;
attribute name __user, __read_mostly;
@@

+#ifdef CONFIG_KSU
+extern bool ksu_vfs_read_hook __read_mostly;
+extern __attribute__((cold)) int ksu_handle_sys_read(unsigned int fd,
+				char __user **buf_ptr, size_t *count_ptr);
+#endif
read(unsigned int fd, char __user *buf, size_t count) {
...
(
+#ifdef CONFIG_KSU
+	if (unlikely(ksu_vfs_read_hook))
+		ksu_handle_sys_read(fd, &buf, &count);
+#endif
  return ksys_read(fd, buf, count);
|
+#ifdef CONFIG_KSU
+	if (unlikely(ksu_vfs_read_hook))
+		ksu_handle_sys_read(fd, &buf, &count);
+#endif
  ret = vfs_read(..., buf, count, &pos);
)
...
}

// File: fs/stat.c
// Adds hook to SYSCALL_DEFINE4(newfstatat, ...)

@sys_newfstatat_hook_minimized depends on file in "fs/stat.c" exists@
identifier dfd, filename, flag, error, stat;
attribute name __user;
@@

+#ifdef CONFIG_KSU
+extern __attribute__((hot)) int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
+#endif
newfstatat(int dfd, const char __user *filename, ..., int flag) {
...
+#ifdef CONFIG_KSU
+	ksu_handle_stat(&dfd, &filename, &flag);
+#endif
error = vfs_fstatat(dfd, filename, &stat, flag);
...
}

// File: fs/stat.c
// Adds hook to SYSCALL_DEFINE4(fstatat64, ...).

@sys_fstatat64_hook_minimized depends on file in "fs/stat.c" exists@
identifier dfd, filename, stat, flag, error;
attribute name __user;
@@

+#ifdef CONFIG_KSU
+extern __attribute__((hot)) int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
+#endif
fstatat64(int dfd, const char __user *filename, ..., int flag) {
...
+#ifdef CONFIG_KSU // 32-bit su
+	ksu_handle_stat(&dfd, &filename, &flag);
+#endif
error = vfs_fstatat(dfd, filename, &stat, flag);
...
}

// File: drivers/input/input.c
// Adds hook to input_event(...).

@input_event_hook_minimized depends on file in "drivers/input/input.c"@
identifier dev, typ, code, value;
attribute name __read_mostly;
statement S1, S2;
@@

+#if defined(CONFIG_KSU_KPROBES_HOOK) || defined(CONFIG_KSU_HOOK_KPROBES) || defined(CONFIG_KSU_WITH_KPROBES)
+#error KernelSU: Manual hooks are incompatible with CONFIG_KSU_KPROBES_HOOK, CONFIG_KSU_HOOK_KPROBES, or CONFIG_KSU_WITH_KPROBES. Disable them in your defconfig and/or KSU config.
+#endif
+
+#ifdef CONFIG_KSU
+extern bool ksu_input_hook __read_mostly;
+extern __attribute__((cold)) int ksu_handle_input_handle_event(
+			unsigned int *type, unsigned int *code, int *value);
+#endif
input_event(struct input_dev *dev, unsigned int typ, unsigned int code, int value) {
... when != S1
+#ifdef CONFIG_KSU
+	if (unlikely(ksu_input_hook))
+		ksu_handle_input_handle_event(&typ, &code, &value);
+#endif
S2
...
}

// Alternative for Linux >= 5.4
// File: drivers/input/input.c
// Adds hook to input_handle_event(...).

@input_event_hook_minimized_alternative depends on file in "drivers/input/input.c" && never input_event_hook_minimized@
identifier dev, typ, code, value;
attribute name __read_mostly;
statement S1, S2;
@@

+#if defined(CONFIG_KSU_KPROBES_HOOK) || defined(CONFIG_KSU_HOOK_KPROBES) || defined(CONFIG_KSU_WITH_KPROBES)
+#error KernelSU: You're using manual hooks but you also enabled CONFIG_KSU_KPROBES_HOOK or CONFIG_KSU_HOOK_KPROBES or CONFIG_KSU_WITH_KPROBES. Disable all of them in your defconfig and/or KSU config.
+#endif
+
+#ifdef CONFIG_KSU
+extern bool ksu_input_hook __read_mostly;
+extern __attribute__((cold)) int ksu_handle_input_handle_event(
+			unsigned int *type, unsigned int *code, int *value);
+#endif
input_handle_event(struct input_dev *dev, unsigned int typ, unsigned int code, int value) {
... when != S1
+#ifdef CONFIG_KSU
+	if (unlikely(ksu_input_hook))
+		ksu_handle_input_handle_event(&typ, &code, &value);
+#endif
S2
...
}


@has_can_umount@
identifier path, flags;
@@
can_umount(const struct path *path, int flags) { ... }

// Backport for Linux < 5.9
// File: fs/namespace.c
@path_umount depends on file in "fs/namespace.c" && never has_can_umount@
@@
do_umount(...) { ... }
+static int can_umount(const struct path *path, int flags)
+{
+struct mount *mnt = real_mount(path->mnt);
+
+if (flags & ~(MNT_FORCE | MNT_DETACH | MNT_EXPIRE | UMOUNT_NOFOLLOW))
+  return -EINVAL;
+if (!ns_capable(current->nsproxy->mnt_ns->user_ns, CAP_SYS_ADMIN))
+  return -EPERM;
+if (path->dentry != path->mnt->mnt_root)
+  return -EINVAL;
+if (!check_mnt(mnt))
+  return -EINVAL;
+#ifdef MNT_LOCKED /* Only available on Linux 3.12+ https://github.com/torvalds/linux/commit/5ff9d8a65ce80efb509ce4e8051394e9ed2cd942 */
+if (mnt->mnt.mnt_flags & MNT_LOCKED) /* Check optimistically */
+  return -EINVAL;
+#endif
+if (flags & MNT_FORCE && !capable(CAP_SYS_ADMIN))
+  return -EPERM;
+return 0;
+}
+
+int path_umount(struct path *path, int flags)
+{
+struct mount *mnt = real_mount(path->mnt);
+int ret;
+
+ret = can_umount(path, flags);
+if (!ret)
+  ret = do_umount(mnt, flags);
+
+/* we mustn't call path_put() as that would clear mnt_expiry_mark */
+dput(path->dentry);
+mntput_no_expire(mnt);
+return ret;
+}



// File: include/linux/cred.h
@has_get_cred_rcu depends on file in "include/linux/cred.h"@
@@
get_cred_rcu(const struct cred *cred) { ... }

// File: include/linux/cred.h
// Backport for Linux < 5.0
@get_cred_rcu_h depends on file in "include/linux/cred.h" && never has_get_cred_rcu@
@@

get_cred(...) { ... }

+static inline const struct cred *get_cred_rcu(const struct cred *cred)
+{
+	struct cred *nonconst_cred = (struct cred *) cred;
+	if (!cred)
+		return NULL;
+#ifdef atomic_inc_not_zero
+	if (!atomic_inc_not_zero(&nonconst_cred->usage))
+		return NULL;
+#else
+	if (!atomic_long_inc_not_zero(&nonconst_cred->usage))
+		return NULL;
+#endif
+	validate_creds(cred);
+	return cred;
+}

// File: kernel/cred.c
// Backport for Linux < 5.0
@get_cred_rcu depends on file in "kernel/cred.c"@
identifier atomic_inc_not_zero =~ "atomic_inc_not_zero|atomic_long_inc_not_zero";
@@

get_task_cred(...) {
...
do { ... } while (
-!atomic_inc_not_zero(&((struct cred *)cred)->usage)
+!get_cred_rcu(cred)
	);
...
}

// File: include/linux/cred.h
// Backport for Linux < 4.15
@has_groups_sort_h depends on file in "include/linux/cred.h"@
@@
extern void groups_sort(struct group_info *);

// Note: for some reason if I don't have a - line that patch never applies... Maybe a bug from Coccinelle?
// So instead of putting the line as an anchor, I put it with a - and then a + and it somehow fixes the problem
@groups_sort_h depends on file in "include/linux/cred.h" && never has_groups_sort_h@
@@
-extern bool may_setgroups(void);
+extern bool may_setgroups(void);
+extern void groups_sort(struct group_info *);

// File: kernel/groups.c
// Backport for Linux < 4.15
@groups_sort depends on file in "kernel/groups.c"@
@@
-static void groups_sort(struct group_info *group_info)
+void groups_sort(struct group_info *group_info)
{
	...
}
+EXPORT_SYMBOL(groups_sort);



// File: kernel/reboot.c
// Adds hook to SYSCALL_DEFINE4(reboot, ...)

@sys_reboot_hook depends on file in "kernel/reboot.c"@
identifier magic1, magic2, cmd, arg;
identifier pid_ns;
type T_ARG;
@@

+#ifdef CONFIG_KSU
+extern int ksu_handle_sys_reboot(int magic1, int magic2, unsigned int cmd, void __user **arg);
+#endif
+
reboot(int magic1, int magic2, unsigned int cmd, T_ARG arg)
{
...
+#ifdef CONFIG_KSU
+	ksu_handle_sys_reboot(magic1, magic2, cmd, &arg);
+#endif
  if (!ns_capable(pid_ns->user_ns, CAP_SYS_BOOT))
		return -EPERM;
...
}



// File: security/selinux/avc.c
@avc_header depends on file in "security/selinux/avc.c"@
@@

avc_audit_post_callback(...) { ... }
+
+#ifdef CONFIG_KSU_EXTRAS
+extern int ksu_handle_slow_avc_audit(u32 *tsid);
+#endif
+



// Insert hook avc.c
@avc_body depends on file in "security/selinux/avc.c"@
typedef u32, u16;
identifier ssid, tclass, req, aud, den, res, state, a;
identifier tsid;
@@

slow_avc_audit(struct selinux_state *state, u32 ssid, u32 tsid, u16 tclass, u32 req, u32 aud, u32 den, int res, struct common_audit_data *a)
{
...
+
+#ifdef CONFIG_KSU_EXTRAS
+	ksu_handle_slow_avc_audit(&tsid);
+#endif
+
if (!a) { ... }
...
}
