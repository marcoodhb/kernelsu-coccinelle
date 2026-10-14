// Coccinelle scope-minimized patches for KernelSU
// From: https://github.com/backslashxx/KernelSU/issues/5#issuecomment-2878532104


// File: fs/exec.c
// Adds hook to do_execveat_common()

@do_execveat_common_hook depends on file in "fs/exec.c"@
@@

+#ifdef CONFIG_KSU_MANUAL_HOOK
+extern int ksu_handle_execveat(int *fd, struct filename **filename_ptr,
+				void *argv, void *envp, int *flags);
+extern int ksu_handle_post_execveat(int *fd, struct filename **filename_ptr,
+				void *argv, void *envp, int *flags, int *retval);
+#endif
+
static int do_execveat_common(int fd, struct filename *filename,
			      struct user_arg_ptr argv,
			      struct user_arg_ptr envp,
			      int flags)
{
+#ifdef CONFIG_KSU_MANUAL_HOOK
+	int retval;
+	ksu_handle_execveat(&fd, &filename, &argv, &envp, &flags);
+
+	retval = __do_execve_file(fd, filename, argv, envp, flags, NULL);
+
+	ksu_handle_post_execveat(&fd, &filename, &argv, &envp, &flags, &retval);
+
+	return retval;
+#else
	return __do_execve_file(fd, filename, argv, envp, flags, NULL);
+#endif
}


// File: fs/open.c
// Adds hook to SYSCALL_DEFINE3(faccessat, ...)

@sys_faccessat_hook depends on file in "fs/open.c"@
attribute name __user;
@@

+#ifdef CONFIG_KSU_MANUAL_HOOK
+extern int ksu_handle_faccessat(int *dfd, const char __user **filename_user,
+				int *mode, int *flags);
+#endif
+
faccessat(int dfd, const char __user *filename, int mode)
{
+#ifdef CONFIG_KSU_MANUAL_HOOK
+	ksu_handle_faccessat(&dfd, &filename, &mode, NULL);
+#endif
	return do_faccessat(dfd, filename, mode);
}


// File: fs/stat.c
// Declaraciones de stat: justo despues del cierre de SYSCALL_DEFINE2(newlstat, ...),
// igual que la guia de BakaSU (incluye fstat64_ret: el check de BakaSU lo exige con CONFIG_COMPAT=y)

@stat_decls depends on file in "fs/stat.c"@
identifier filename, statbuf;
attribute name __user;
@@

newlstat(const char __user *filename, struct stat __user *statbuf)
{
...
}
+
+#ifdef CONFIG_KSU_MANUAL_HOOK
+extern int ksu_handle_stat(int *dfd, const char __user **filename_user,
+				int *flags);
+
+extern void ksu_handle_newfstat_ret(unsigned int *fd, struct stat __user **statbuf_ptr);
+#if defined(__ARCH_WANT_STAT64) || defined(__ARCH_WANT_COMPAT_STAT64)
+extern void ksu_handle_fstat64_ret(unsigned long *fd, struct stat64 __user **statbuf_ptr);
+#endif
+#endif


// File: fs/stat.c
// Adds hook to SYSCALL_DEFINE4(newfstatat, ...)

@sys_newfstatat_hook depends on file in "fs/stat.c" exists@
identifier dfd, filename, flag, error, stat;
attribute name __user;
@@

newfstatat(int dfd, const char __user *filename, ..., int flag) {
...
+#ifdef CONFIG_KSU_MANUAL_HOOK
+	ksu_handle_stat(&dfd, &filename, &flag);
+#endif
error = vfs_fstatat(dfd, filename, &stat, flag);
...
}

// File: fs/stat.c
// Adds return hook to SYSCALL_DEFINE2(newfstat, ...)

@sys_newfstat_ret_hook depends on file in "fs/stat.c" exists@
identifier fd, statbuf, stat, error;
attribute name __user;
@@

newfstat(unsigned int fd, struct stat __user *statbuf) {
...
if (!error)
	error = cp_new_stat(&stat, statbuf);
+#ifdef CONFIG_KSU_MANUAL_HOOK
+	ksu_handle_newfstat_ret(&fd, &statbuf);
+#endif
return error;
}


// File: fs/stat.c
// Adds return hook to SYSCALL_DEFINE2(fstat64, ...)
// Solo existe si el arbol compila fstat64 (arm64 con CONFIG_COMPAT)

@sys_fstat64_ret_hook depends on file in "fs/stat.c" exists@
identifier fd, statbuf, stat, error;
attribute name __user;
@@

fstat64(unsigned long fd, struct stat64 __user *statbuf) {
...
if (!error)
	error = cp_new_stat64(&stat, statbuf);
+#ifdef CONFIG_KSU_MANUAL_HOOK
+	ksu_handle_fstat64_ret(&fd, &statbuf);
+#endif
return error;
}


// File: kernel/reboot.c
// Adds hook to SYSCALL_DEFINE4(reboot, ...)

@sys_reboot_hook depends on file in "kernel/reboot.c"@
attribute name __user;
@@

+#ifdef CONFIG_KSU_MANUAL_HOOK
+extern int ksu_handle_sys_reboot(int magic1, int magic2, unsigned int cmd, void __user **arg);
+#endif
+
reboot(int magic1, int magic2, unsigned int cmd, void __user *arg)
{
...
int ret = 0;
+#ifdef CONFIG_KSU_MANUAL_HOOK
+	ksu_handle_sys_reboot(magic1, magic2, cmd, &arg);
+#endif
...
}

