module VinylFix

public abstract class VinylFixTargets {
  // Record player entities: V's apartments (H10, Japantown, Glen,
  // Corpo Plaza), Kerry's gift from sq028, the epilogue and Dogtown ones,
  // and the generic device template.
  public static func RecordPlayerTemplates() -> array<ResRef> {
    return [
      r"base\\gameplay\\devices\\custom\\vinyl_record_player.ent",
      r"base\\items\\quest\\sq028__record_player_a.ent",
      r"base\\quest\\side_quests\\sq028\\entities\\sq028_record_player.ent",
      r"base\\quest\\main_quests\\epilogue\\q204\\entities\\q204_record_player.ent",
      r"dlc\\dlc6_apart\\loc_dlc6_apart_wbr_jpn\\quest\\entities\\dlc6_apart_wbr_jpn_record_player.ent",
      r"dlc\\dlc6_apart\\loc_dlc6_apart_cct_dtn\\quest\\entities\\dlc6_apart_cct_dtn_record_player.ent",
      r"dlc\\dlc6_apart\\loc_dlc6_apart_hey_gle\\quest\\entities\\dlc6_apart_hey_gle_record_player.ent",
      r"ep1\\items\\quest\\q305__record_player.ent"
    ];
  }

  // Record disc meshes that may be placed as rotating world nodes.
  public static func RecordMeshes() -> array<ResRef> {
    return [
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_default.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_a_record_a.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_b_record_a.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_c_record_a.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_d_record_a.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_e_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_f_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_g_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_h_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_i_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_j_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_k_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_l_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_m_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_m_tainted_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_n_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_n_tainted_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_o_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_o_tainted_record.mesh",
      r"base\\environment\\decoration\\misc\\music\\vinyl\\vinyl_p_record.mesh"
    ];
  }

  public static func IsRecordMesh(path: ResRef) -> Bool {
    for mesh in VinylFixTargets.RecordMeshes() {
      if Equals(mesh, path) {
        return true;
      }
    }
    return false;
  }
}
