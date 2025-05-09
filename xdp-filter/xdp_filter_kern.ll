; ModuleID = 'xdp_filter_kern.c'
source_filename = "xdp_filter_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !0
@llvm.compiler.used = appending global [2 x ptr] [ptr @_license, ptr @xdp_prog_simple], section "llvm.metadata"

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, inaccessiblemem: none)
define dso_local range(i32 1, 3) i32 @xdp_prog_simple(ptr nocapture noundef readonly %0) #0 section "xdp" !dbg !33 {
    #dbg_value(ptr %0, !49, !DIExpression(), !52)
    #dbg_value(i32 2, !50, !DIExpression(), !52)
  %2 = load i32, ptr %0, align 4, !dbg !53, !tbaa !54
  %3 = zext i32 %2 to i64, !dbg !59
  %4 = add nuw nsw i64 %3, 42, !dbg !60
  %5 = inttoptr i64 %4 to ptr, !dbg !61
    #dbg_value(ptr %5, !51, !DIExpression(), !52)
  %6 = getelementptr inbounds i8, ptr %5, i64 1, !dbg !62
  %7 = getelementptr inbounds i8, ptr %0, i64 4, !dbg !64
  %8 = load i32, ptr %7, align 4, !dbg !64, !tbaa !65
  %9 = zext i32 %8 to i64, !dbg !66
  %10 = inttoptr i64 %9 to ptr, !dbg !67
  %11 = icmp ult ptr %6, %10, !dbg !68
  br i1 %11, label %12, label %16, !dbg !69

12:                                               ; preds = %1
  %13 = load i8, ptr %5, align 1, !dbg !70, !tbaa !73
  %14 = icmp eq i8 %13, 48, !dbg !74
  br i1 %14, label %15, label %16, !dbg !75

15:                                               ; preds = %12
    #dbg_value(i32 1, !50, !DIExpression(), !52)
  br label %16, !dbg !76

16:                                               ; preds = %12, %15, %1
  %17 = phi i32 [ 1, %15 ], [ 2, %12 ], [ 2, %1 ], !dbg !52
    #dbg_value(i32 %17, !50, !DIExpression(), !52)
  ret i32 %17, !dbg !78
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(read, inaccessiblemem: none) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!27, !28, !29, !30, !31}
!llvm.ident = !{!32}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 34, type: !23, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "clang version 19.1.7", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !14, globals: !22, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "xdp_filter_kern.c", directory: "/home/axel/Studium/Semester_10/Advanced_Topics_in_Software_Systems_Design_and_Implementation/project/xdp-tutorial/filter", checksumkind: CSK_MD5, checksum: "25eada17d2a144f51ace7bc29af9d42a")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 6448, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "/usr/include/linux/bpf.h", directory: "", checksumkind: CSK_MD5, checksum: "9b24ac50b5527820e4640122908e0a1e")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2)
!12 = !DIEnumerator(name: "XDP_TX", value: 3)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!14 = !{!15, !21}
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !16, size: 64)
!16 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !17, line: 24, baseType: !18)
!17 = !DIFile(filename: "/usr/include/bits/stdint-uintn.h", directory: "", checksumkind: CSK_MD5, checksum: "006a4d9ce94ea5734db820ef3fdd4790")
!18 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !19, line: 38, baseType: !20)
!19 = !DIFile(filename: "/usr/include/bits/types.h", directory: "", checksumkind: CSK_MD5, checksum: "0737a53e1b85eab0e0ba9675962d13f4")
!20 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!21 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!22 = !{!0}
!23 = !DICompositeType(tag: DW_TAG_array_type, baseType: !24, size: 32, elements: !25)
!24 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!25 = !{!26}
!26 = !DISubrange(count: 4)
!27 = !{i32 7, !"Dwarf Version", i32 5}
!28 = !{i32 2, !"Debug Info Version", i32 3}
!29 = !{i32 1, !"wchar_size", i32 4}
!30 = !{i32 7, !"frame-pointer", i32 2}
!31 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!32 = !{!"clang version 19.1.7"}
!33 = distinct !DISubprogram(name: "xdp_prog_simple", scope: !3, file: !3, line: 17, type: !34, scopeLine: 18, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !48)
!34 = !DISubroutineType(types: !35)
!35 = !{!36, !37}
!36 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!37 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !38, size: 64)
!38 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 6459, size: 192, elements: !39)
!39 = !{!40, !43, !44, !45, !46, !47}
!40 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !38, file: !6, line: 6460, baseType: !41, size: 32)
!41 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !42, line: 27, baseType: !7)
!42 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "", checksumkind: CSK_MD5, checksum: "b810f270733e106319b67ef512c6246e")
!43 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !38, file: !6, line: 6461, baseType: !41, size: 32, offset: 32)
!44 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !38, file: !6, line: 6462, baseType: !41, size: 32, offset: 64)
!45 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !38, file: !6, line: 6464, baseType: !41, size: 32, offset: 96)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !38, file: !6, line: 6465, baseType: !41, size: 32, offset: 128)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "egress_ifindex", scope: !38, file: !6, line: 6467, baseType: !41, size: 32, offset: 160)
!48 = !{!49, !50, !51}
!49 = !DILocalVariable(name: "ctx", arg: 1, scope: !33, file: !3, line: 17, type: !37)
!50 = !DILocalVariable(name: "verdict", scope: !33, file: !3, line: 19, type: !36)
!51 = !DILocalVariable(name: "udp_bytes", scope: !33, file: !3, line: 21, type: !15)
!52 = !DILocation(line: 0, scope: !33)
!53 = !DILocation(line: 21, column: 39, scope: !33)
!54 = !{!55, !56, i64 0}
!55 = !{!"xdp_md", !56, i64 0, !56, i64 4, !56, i64 8, !56, i64 12, !56, i64 16, !56, i64 20}
!56 = !{!"int", !57, i64 0}
!57 = !{!"omnipotent char", !58, i64 0}
!58 = !{!"Simple C/C++ TBAA"}
!59 = !DILocation(line: 21, column: 34, scope: !33)
!60 = !DILocation(line: 21, column: 91, scope: !33)
!61 = !DILocation(line: 21, column: 23, scope: !33)
!62 = !DILocation(line: 24, column: 17, scope: !63)
!63 = distinct !DILexicalBlock(scope: !33, file: !3, line: 24, column: 6)
!64 = !DILocation(line: 24, column: 45, scope: !63)
!65 = !{!55, !56, i64 4}
!66 = !DILocation(line: 24, column: 34, scope: !63)
!67 = !DILocation(line: 24, column: 24, scope: !63)
!68 = !DILocation(line: 24, column: 22, scope: !63)
!69 = !DILocation(line: 24, column: 6, scope: !33)
!70 = !DILocation(line: 26, column: 7, scope: !71)
!71 = distinct !DILexicalBlock(scope: !72, file: !3, line: 26, column: 7)
!72 = distinct !DILexicalBlock(scope: !63, file: !3, line: 24, column: 55)
!73 = !{!57, !57, i64 0}
!74 = !DILocation(line: 26, column: 18, scope: !71)
!75 = !DILocation(line: 26, column: 7, scope: !72)
!76 = !DILocation(line: 28, column: 3, scope: !77)
!77 = distinct !DILexicalBlock(scope: !71, file: !3, line: 26, column: 26)
!78 = !DILocation(line: 31, column: 2, scope: !33)
